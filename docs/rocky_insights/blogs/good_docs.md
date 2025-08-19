---
title: Good Docs-A translator's viewpoint
author: Ganna Zhyrnova
contributors: Steven Spencer
---

## Introduction

Translators provide valuable insight into writing clear, concise documentation. They know what does not translate well and what confuses a reader better than most. This document examines some of those issues and highlights best practices for document creation.

### From the author

Software documentation helps users understand how to use a particular software effectively. They need to understand what they will have at the end and what benefits they will have. At the same time, when you create documentation, it means that you create it not only for yourself but also for your network and for other people who might read it. Other people might not be from English-speaking countries. It means that for them, English is not their primary language. Because of this, follow these basic rules to make your documentation more readable for *all* users.

## Use plain language

You have no idea who your user is. Whether this user is familiar with this sphere or not, whether they are a skilled developer or a beginner. Plain language is communication that is clear, concise, and easy for the intended audience to understand the first time they encounter it. It avoids jargon, technical terms, and complex sentence structures in favor of simpler language and clear organization. The goal is to ensure that the message is accessible and understandable to a broad audience, regardless of their background or reading level. Often, you can do this by simplifying sentence structures or commands down to their most basic format.

## Avoid idioms, jargon, acronyms, and contractions

Idioms, jargon, contractions, and acronyms can confuse readers who are unfamiliar with them, especially non-native speakers, new employees, or people outside your specific domain.

**Idioms** are often culturally specific and can be difficult for international readers to understand.  
**Jargon** involves specialized terms that only experts in a field might recognize.  
**Contractions** replace words in the English language with shortcuts, but these do not always exist in all languages, making translation difficult.  
**Acronyms** can be ambiguous, especially if not defined when first used.  

Example:

❌ "Once you’ve got the hang of the dashboard, the rest is a piece of cake." Here, the author uses both a contraction, slang, and an idiom.

 ✅ "Once you have learned how to use the dashboard, the rest is easy." By replacing the contraction, the slang, and the idiom with the words associated with each, the meaning is clear.

Figurative language, such as idioms, often does not translate well. Technical writers or translators might struggle to convey the same meaning in other languages.

Example:

❌ "Let’s touch base next week to circle back on the open tickets."

 ✅ "Let us meet next week to review the unresolved support requests."

Jargon and acronyms can be confusing—even within the same organization—if their meanings are not universally known.

Example:

❌ "Upload the CSV to the CMS and tag it according to SOPs."

 ✅ "Upload the CSV (Comma-Separated Values file) to the content management system and label it according to the standard operating procedures."

Note: If you want to use acronyms, always define them the first time: “Customer Relationship Management (CRM) system”.

By eliminating idioms and unnecessary jargon, the meaning of your document becomes clearer. Replacing contractions with the words they represent, means that translation efforts in all languages are easier. Your document is the most understandable to the reader when you replace or define acronyms.

## Use active voice

Active voice emphasizes the doer of the action, making it clear who or what is responsible for the action of the verb.

Example:

The system opens the dialog where you need to complete the form.

Please refrain from using the complex form, as it can be confusing for readers.

For more on the use of active voice and the importance of using it, see [this opinion](active_voice.md) and [this outside source](https://developers.google.com/tech-writing/one/active-voice).

## Specific steps

If you have specific steps in the documentation, separate them from one another.

For example:

Step 1 - Go to the section  
Step 2 - Click the button  
Step 3 - Complete the form  
...  
Step N - save changes

## Screenshots when necessary

Use correct screenshots where needed. This means that you do not need to add screenshots everywhere, only in places where you need further explanation.

## Use examples

If you need to fill out the form, then provide examples of how users can complete it. Mention limitations if they have them.

## Conclusion

Writing good documentation is not just making it technically accurate, it is also very important to make it instantly understandable to the reader. This is particularly important when a technical document needs translation into other languages. Within this document, it was the author's intent to highlight specific techniques for writing good, clear, documentation.
