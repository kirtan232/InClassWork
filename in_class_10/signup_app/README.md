# signup_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Track-Based Critical Thinking
Undergraduate:

Question 1: Trace the local tip feature from button tap to displayed text. Which widget/state changes during the simulated loading state, and how does the user recover from the local error case?

Answer 1: When I tap the "get a tip" button it calls the _getTip() function. Then it uses the setState to set the _loading to true and this also resets the old response to show the new response which is the same unless I check the offline button. So after a one second wait setState either prints the text or sets _error which shows a red message.

Question 2: Why must the app keep form validation local even when it can ask an AI for a tip? Give one example of a bad decision if AI were allowed to approve signup.

Answer 2: The validation are fixed ruls and don't need the network. If we allow the AI to sign up it might approve signups without metting the requirment becasue it can be wrong some times.

Question 3: Which fixed local category selects the tip, and what form information does the feature deliberately ignore? Why?

Answer 3: The tips always used the password_help, which sent with the task table label signup_tip.The feature ignores everthing typed into the form including the name, email, and the password. This info should never leave and be givin to ai for tips.

Question 4: Which local test case changed what you implemented? Describe what you observed.

Answer 4: At first the tip always succeeded, so there was no way to get fails. I added the Pretend offline check box to we can see the error. So when I check it the app pretents to go ofline and gives a red message and try again button.

