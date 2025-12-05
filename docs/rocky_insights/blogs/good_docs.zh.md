---
title: 优质文档规范——译者视角
author: Ganna Zhyrnova
contributors: Steven Spencer
---

## 介绍

译者能为撰写清晰简明的文档提供宝贵洞见。 他们比大多数人更清楚哪些内容难以准确翻译、哪些表述容易引发读者困惑。 本文剖析了此类典型问题，并聚焦优质文档创作的最佳实践指南。

### 来自作者

软件文档帮助用户理解如何高效使用特定软件。 用户需要明确了解最终能实现什么成果以及获得哪些收益。 同时，在创建文档时应当意识到，您不仅是为自己编写，更是为技术社群及其他可能阅读的人而写作。 其他人可能不是来自英语国家。 这意味着对他们来说，英语不是他们的主要语言。 因此，遵循这些基本规则，使您的文档对 _所有_ 用户都更具可读性。

## 使用通俗易懂的语言

您根本不知道您的用户是谁。 无论这个用户是否熟悉这个领域，无论他们是经验丰富的开发者还是初学者。 通俗易懂的语言是清晰、简洁且能让目标受众在初次接触时就能理解的交流方式。 应避免使用行话、技术术语和复杂的句子结构，而应该倾向于使用更简单的语言和清晰的组织方式。 其目标是确保信息对广泛的受众来说都是可获取且易于理解的，无论他们的背景或阅读水平如何。 通常，您可以通过将句子结构或命令简化到最基本的格式来做到这一点。

## 避免使用习语、术语、首字母缩略词和缩略形式

习语、术语、缩略形式和首字母缩略词可能会让不熟悉它们的读者感到困惑，尤其是非母语人士、新员工或特定领域之外的人。

**习语** 通常具有文化特殊性，对于国际读者来说很难理解。  
**术语** 涉及只有某一领域的专家才能识别的专业术语。  
**缩略形式** 在英语中用简化形式替代完整词汇，但并非所有语言都存在类似用法，导致翻译困难。  
**首字母缩略词** 易产生歧义，尤其是在首次使用时没有定义的情况下。

示例：

❌ "Once you’ve got the hang of the dashboard, the rest is a piece of cake." 在这里，作者使用了缩略形式、俚语和习语。

✅ "Once you have learned how to use the dashboard, the rest is easy." 通过将缩略形式、俚语和习语替换为与之相关的词语，意思就清晰了。

诸如习语之类的比喻性语言通常难以翻译。 技术作者或翻译人员可能很难在其他语言中传达相同的意思。

示例：

❌ "Let’s touch base next week to circle back on the open tickets."

✅ "Let us meet next week to review the unresolved support requests."

术语和首字母缩略词若未被普遍知晓，即使在同一个组织内部也可能造成混淆。

示例：

❌ "Upload the CSV to the CMS and tag it according to SOPs."

✅ "Upload the CSV (Comma-Separated Values file) to the content management system and label it according to the standard operating procedures."

注意：如果你想使用首字母缩略词，请务必在第一次定义它们："Customer Relationship Management (CRM) system"。

通过消除习语和不必要的术语，文档的含义会变得更加清晰。 将缩略形式替换为其代表的完整词语，意味着所有语言的翻译工作都会变得更容易。 当您替换或定义首字母缩略词时，您的文档对读者来说是最易理解的。

## 使用主动语态

主动语态强调动作的执行者，明确指出谁或什么对动词所表示的动作负责。

示例：

The system opens the dialog where you need to complete the form.

请避免使用复数形式，因为它会让读者感到困惑。

有关主动语态的使用以及使用它的意义，请参阅 [此观点](active_voice.md) 和 [此外部来源](https://developers.google.com/tech-writing/one/active-voice)。

## 具体步骤

如果文档中有特定的步骤，请将它们分开。

例如：

Step 1 - Go to the section  
Step 2 - Click the button  
Step 3 - Complete the form  
...  
Step N - save changes

## 必要时进行截图

在需要的地方使用正确的截图。 这意味着您无需到处添加截图，仅在需要进一步解释的地方添加即可。

## 使用示例

如果你需要填写表格，那么请提供用户如何填写的示例。 如果有任何限制，请一并说明。

## 总结

编写好的文档，不仅要确保其技术上的准确性，还要让读者能够立刻理解。 这一点在技术文档需要翻译成其他语言时尤为重要。 在这份文档中，作者旨在强调编写优质、清晰文档的特定技巧。
