# hw1 report

|Field|Value|
|-:|:-|
|Name|洪慎廷|
|ID|110550162|

## How much time did you spend on this project

e.g. 2 hours.

About 3 hours.

## Project overview

Describe the project structure and how you implemented it.

My project structure includes three parts, definitions, transition rules and user subroutines. However, I didn't add any code in the last part. Thus, the following is my description of the definitions and transition rules.

For the definition part, I defined two regular definitions, "digit" and "letter", and two start conditions, "ONELINE_COMMENT" and "MULTILINE_COMMENT". The definition of "digit" is the numbers from zero to nine, and "letter" is the lower and upper letters from 'a' to 'z'. The condition, "ONELINE_COMMENT" and "MULTILINE_COMMENT", are both used for recognizing the comments, but the former is for the one-line comment "//" and the latter is for the multiline comment "/**/".

For the transition rule part, all the tokens are identified by the regular expressions that I've written. For those need to be passed to the parser are put in the provided function, "LIST_TOKEN" and "LIST_LITERAL", and for those will be discarded, are put in the function "LIST_SOURCE". All the regular expressions, except the newline '\n', are specified in a condition, either "INITIAL", "ONELINE_COMMENT" or "MULTILINE_COMMENT". Most of the time the condition stays in "INITIAL". It switches to "ONELINE_COMMENT" only when reading the one-line comment or persudocomments, and it switches to "ONELINE_COMMENT" only when reading the multiline comment.

## What is the hardest you think in this project

Let us know, if any.

The hardest part I think is doing the string processing for the string constants.It is the part that took me the most time. Though, it still isn't a big deal, just using the knowledge I learned in C language.

## Feedback to T.A.s

> Please help us improve our assignment, thanks.
