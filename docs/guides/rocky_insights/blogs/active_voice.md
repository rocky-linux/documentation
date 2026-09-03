---
author: Steven Spencer
contributors:
---

# Active voice: The way to simple, clear, communication

## Active verses passive voice

There is a huge debate these days on the use of active voice in documentation. There should not be. The reason is that using active voice helps create documentation that is direct and clear. I read a social media post recently where they were questioning this reality. The gist of the conversation was: *'Passive voice does not seem that bad in documentation, should I care?'* I can assure you that it **does** matter, and you **should** care. Passive voice is often ambiguous and unclear. Passive voice can lead to confusion in technical writing, particularly where your audience varies and where translations occur. Our goal with Rocky Linux documentation is to have great documentation, and great documentation does not include the use of passive voice. Examine this from our "Style Guide":

> Say what you mean in as few words as possible.

Active voice forces this. Here is an example of a passive voice instruction:

For our web platform, Apache must be installed using this command: `sudo dnf install httpd`

While here is the active voice equal:

For your web platform, install Apache with this command: `sudo dnf install httpd`

A couple of things are notable in this example. The passive voice phrase has 11 words while the active voice has 9. The active voice phrase directs the user to "install" Apache, rather than telling them it "must be installed." In both examples, though, the instruction, the most important element, hides in the body of the sentence. While 9 words is an improvement, we can do more. If you remember the "Say what you mean in as few words as possible" rule, then consider this:

Install Apache with: `sudo dnf install httpd`

Again, we use active voice, but now just 3 words instead of 9 (or 11). In addition, our instruction could not be more clear. It is simple and direct. This has repercussions for translation, and document structure. Translating 3 words takes less effort for our translators. The 3 word instruction is clear to your readers. It is a win all around.

When striving for clear instructions, combining simplification with active voice helps in achieving your goal.

## Identifying passive voice

When I first started writing documentation for Rocky Linux back in 2021, I started with a cache of documents I wrote when still working as a network administrator. My documents were full of passive voice phrasing, and at the time, I could not identify them easily. It was not until late 2023 that the editor that I began to use for both creating and editing documents ([Neovim based](https://neovim.io/) editor with [Vale](https://vale.sh/)) started highlighting passive voice phrases. It was difficult to train my eye to "see" the passive voice phrases at a glance. It still is not always easy to see. Here are things to watch for to help identify passive voice:

* Instructions starting with or including 'we' or 'our'

    These almost always lead to phrasing that is first, indirect, and often includes passive voice. Use 'you' or 'your' in your writing of instructions.

* Watch for verbs such as: 'was', 'were', 'are', 'been', 'be', and so on, followed by a past participle phrase usually (but not always) ending in "ed." Examples:

    * "was created"
    * "were backed up"
    * "are manipulated"
    * "been restored"
    * "be installed"
    * "is hidden"

    Each of these is an example of passive voice.

* Watch for sentences where the instruction is **not** the first, most important, element (the subject).

You can train your eye to see these when proofreading, but if you stick to a goal of simplifying your instructions, you will find that elimination of passive voice happens without much effort. It is still **very** helpful to use an editor that supports Vale integration.

## Conclusion

Using active voice in your technical writing helps to ensure simple, clear, instructions. In addition, further simplification of your writing enhances readability, understandability, and helps ease translation efforts. Remember: "Say what you mean in as few words as possible."

## More reading

* Tech Whirl - [Avoiding Passive Voice](https://techwhirl.com/avoiding-passive-voice/)
* Google Developers - [Active voice vs. passive voice](https://developers.google.com/tech-writing/one/active-voice)
