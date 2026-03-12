---
title: AI-assisted contribution policy
authors: Wale Soyinka, Steven Spencer, Documentation Team
contributors: Steven Spencer, Ganna Zhyrnova
---

!!! note

    This Rocky Linux Documentation project’s AI-Assisted Contributions Policy is based on and extends the [AI-Assisted Contributions Policy](https://docs.fedoraproject.org/en-US/council/policy/ai-contribution-policy/) developed by the Fedora Project. It is subject to changes and revisions.

You *MAY* use AI assistance for contributing to the Rocky Linux Documentation Project, as long as you follow the principles described below.

## Accountability

- You *MUST* take the responsibility for your contribution.
- Contributing to Rocky Linux means vouching for the quality, license compliance, and utility of your submission.
- All contributions, whether from a human author or assisted by large language models (LLMs) or other generative AI tools, must meet the project’s standards for inclusion.
- The contributor is always the author and is fully accountable for the entirety of these contributions.

## Transparency

- You *MUST* disclose your use of AI tools when a significant part of your contribution comes directly from a tool without any changes.
- You *SHOULD* disclose the other uses of AI tools, where they might be useful.
- Routine use of assistive tools for correcting grammar and spelling, or for clarifying language, does not require disclosure. Information about the use of AI tools will help us evaluate their impact, build new best practices, and adjust existing processes. Authors make disclosures where they normally indicate authorship.
- For contributions tracked in git, the recommended method is an `Assisted-by:` commit message trailer.
- For contributed content, authors must include the disclosure in the document preamble or another document metadata section.

Examples:

  ```text
  ---
  title: 
  author: Steven Spencer
  contributors: Ganna Zhyrnova, Colussi Franco, tianci li, Wale Soyinka 
  ai-contributors: Claude (claude-sonnet-4-20250514), Gemini (gemini-2.5-pro)
  ---
  ```

## Contribution & community evaluation

- AI tools may assist human reviewers by providing analysis and suggestions.
- You *MUST NOT* use AI as the sole or final arbiter in making a substantive or subjective judgment on a contribution, nor may it be used to evaluate a person’s standing within the community (e.g., for funding, leadership roles, or Code of Conduct matters).
- This does not prohibit the use of automated tooling for objective technical validation, such as CI/CD pipelines, automated testing, or spam filtering.
- The final accountability for accepting a contribution, even if implemented by an automated system, always rests with the human contributor who authorizes the action.

## Large-scale initiatives

The policy does not cover large-scale initiatives, which may significantly change how the project operates or lead to exponential growth in contributions in some parts of the project. Such initiatives need to be discussed separately with the project leadership.

## Respect for existing contributions

- You *MUST NOT* submit AI-generated contributions that primarily derive from or substantially rework other contributors’ work.
- AI-assisted edits *SHOULD* preserve the original author’s intent, voice, and structure.

Concerns about possible policy violations should be reported as an [issue via this link](https://github.com/rocky-linux/documentation/issues)

The key words “MAY”, “MUST”, “MUST NOT”, and “SHOULD” in this document are to be interpreted as described in link:<https://datatracker.ietf.org/doc/html/rfc2119>[RFC 2119].
