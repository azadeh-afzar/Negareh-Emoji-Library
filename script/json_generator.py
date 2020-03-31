#!/usr/bin/env python3

# Python Standard Library
import json
import codecs
import copy

def handle_alias_special_case(alias):
    # special aliases causing duplication problems.
    special_cases = [
                     "pretzel",
                     "sunglasses",
                     "pouting_face",
                     "kiss",
                     "horse",
                     "camel",
                     "post_office",
                     "satellite",
                     "umbrella",
                     "snowman",
                     "calendar"
                    ]

    if alias in special_cases:
        alias = list(alias)
        alias.append("2")
        alias = "".join(alias)
        return alias
    elif alias == "flag_åland_islands":
        return "flag_aland_islands"
    else:
        return alias

def create_alias(annotation, category):
    """Create alias from annotation."""
    # clean annotation from bad characters.
    alias = annotation.strip()
    alias = alias.replace("&", "")
    alias = alias.replace("!", "")
    alias = alias.replace("(", "")
    alias = alias.replace(")", "")
    alias = alias.replace("“", "")
    alias = alias.replace("”", "")
    alias = alias.replace("’", "")
    alias = alias.replace("#", "hashtag")
    alias = alias.replace("*", "astrix")
    alias = alias.replace("ä", "a")
    alias = alias.replace("ã", "a")
    # doesn't remove flag_åland_islands :|
    alias = alias.replace("å", "a")
    alias = alias.replace("ç", "c")
    alias = alias.replace("é", "e")
    alias = alias.replace("ô", "o")
    alias = alias.replace("í", "i")
    alias = alias.replace("ñ", "n")
    alias = alias.replace("ü", "u")
    alias = alias.replace(" ", "_")
    alias = alias.replace("-", "_")
    alias = alias.replace(".", "_")
    alias = alias.replace(":", "_")
    alias = alias.replace(",", "_")
    alias = alias.replace("__", "_")
    # handle openmoji extra emojis.
    if category == "Extras & Openmoji":
        alias = list(alias)
        alias.append("-extra")
        alias = "".join(alias)
    # lowercase characters.
    alias = alias.lower()
    return handle_alias_special_case(alias)

def create_new_emoji(emoji, description, category, aliases, tags, unicode_version):
    """base structure for a emoji dictionary."""
    new_dict = {
      "emoji": emoji
    , "description": description
    , "category": category
    , "aliases": [
      aliases
    ]
    , "tags": [
      tags
    ]
    , "unicode_version": f"{unicode_version}.0" if unicode_version is not None else ""
    , "ios_version": f"{unicode_version}.0" if unicode_version is not None else ""
    }
    return new_dict

def generate_negarmoji_json(gemoji_json_file, openmoji_json_file, output_file_path):
    """Generate negarmoji json from combining openmoji json and gemoji json."""

    # read in gemoji and openmoji json files.
    with open(gemoji_json_file, "rb") as read_file:
        gemoji = json.load(read_file)
    with open(openmoji_json_file, "rb") as read_file:
        openmoji = json.load(read_file)

    # collect emojis from emoji dictionaries.
    gemoji_emojis = set([emoji_dict["emoji"] for emoji_dict in gemoji])
    openmoji_emojis = set([emoji_dict["emoji"] for emoji_dict in openmoji])

    # some emojis are same in both gemoji and openmoji emojis but they differ in
    # the end sequence, openmoji usually have an extra \ufe0f character, so in
    # this part of code I'm trying to normalize gemoji dictionary by appending
    # \ufe0f to the end of some emojis which results in a same emoji in
    # the openmoji dictionary.

    # find emojis in gemoji which will be same with an emoji in openmoji if we
    # add \ufe0f at the end of it.
    difference = [
                  (emoji.replace("\ufe0f", ""), emoji)
                  for emoji in openmoji_emojis
                  if emoji.replace("\ufe0f", "") in gemoji_emojis
                 ]

    # normalize gemoji dictionary by replacing emojis.
    for emoji_dict in gemoji:
        for diff in difference:
            if emoji_dict["emoji"] == diff[0]:
                emoji_dict["emoji"] = diff[1]
                break

    # re-create gemoji emojis from normalized gemoji dictionary.
    gemoji_emojis = set([emoji_dict["emoji"] for emoji_dict in gemoji])

    # find difference between openmoji and gemoji. since we have normalized
    # gemoji, in this stage only unique new emojis from openmoji will show up
    # and not the same emojis with and extra \ufe0f at the end of it.
    difference = openmoji_emojis - gemoji_emojis

    # create base negarmoji dictionary from gemoji.
    negarmoji = copy.deepcopy(gemoji)

    # convert new unique emojis from openmoji dictionary type to negarmoji dictionary
    for emoji_dict in openmoji:
        if emoji_dict["emoji"] in difference:
            # filter properties.
            emoji = emoji_dict["emoji"]
            description = emoji_dict["annotation"]
            category = emoji_dict["group"].replace("-", " & ").title()
            aliases = create_alias(emoji_dict["annotation"], category)
            tags = emoji_dict["tags"]
            unicode_version = emoji_dict["unicode"]
            # create emoji dictionary.
            new_emoji_dict = create_new_emoji(emoji, description, category, aliases, tags, unicode_version)
            # add new dictionary to negarmoji dictionary.
            negarmoji.append(new_emoji_dict)

    # add extra aliases for emojis from openmoji annotations.
    for emoji_dict in negarmoji:
        for emoji_dict_2 in openmoji:
            if emoji_dict["emoji"] == emoji_dict_2["emoji"]:
                new_alias = create_alias(emoji_dict_2["annotation"], emoji_dict_2["group"].replace("-", " & ").title())
                if new_alias not in emoji_dict["aliases"]:
                    check_duplicate = list(new_alias)
                    check_duplicate.append("2")
                    check_duplicate = "".join(check_duplicate)
                    if check_duplicate not in emoji_dict["aliases"]:
                        emoji_dict["aliases"].append(new_alias)
                break

    with codecs.open(output_file_path, "w", encoding="utf8") as write_file:
        json.dump(negarmoji, write_file, ensure_ascii=False, indent=4)
