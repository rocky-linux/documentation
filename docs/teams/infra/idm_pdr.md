---
title: PDR delete request
author: Infrastructure team
contributors: Steven Spencer
---

As a user within the Rocky Linux and Rocky Enterprise Software Foundation ecosystem, you have a right to request the deletion of your account and the removal of all personal information. This is as a personal data request (PDR).

## General information

When you request a PDR delete request the following will occur during processing:

* The removal of your personal data and information from your account
* Your removal from all relevant groups in [Account Services](https://accounts.rockylinux.org)
* Your account setting will switch to `private` in [Account Services](https://accounts.rockylinux.org)
* The disabling of your account in [Account Services](https://accounts.rockylinux.org)

If your intention is to keep your account active and hide your personal information, you can set your profile to "private" in Account Services by:

1. Click `Edit Profile`
2. Select the checkbox for `Private`
3. Save.

## Mattermost accounts

While we are working to integrate Mattermost with Rocky Account Services, at this time, Mattermost accounts are still separate and are not included in a typical PDR delete request. If you want to have your Mattermost account removed, you can follow the instructions here and indicate the account you want removed. If submitting by way of email, send from the address associated with the account you want to remove. If you use a different email address, the request will need validation with the account's proper address before acting on the request. For security reasons, we are not able to reveal the email address associated with any account name.

## Submitting a request

Submitting a request requires either, opening a bug tracker issue, opening a ticket in the Infrastructure meta, or making an email request.

### Bug tracker ticket request

1. Open our [Bug Tracker](https://bugs.rockylinux.org) and login with your account (You can do this by clicking "anonymous" and click logout)
2. In the top left corner, click the drop down next to your login name
3. Select "Account Services" as the project.
4. Click "Report Issue"
5. Set category to `Account Requests - Personal Data Request`
6. Set summary as `PDR - Delete Request`
7. Above the description box, click the snippets drop down and select `PDR Request - Remove Personal Information`
8. Fill out the form appropriately. Do not remove data that contains `{}` and ensure you have read the "Information" section. You can add comments as you see fit.
9. Click `Submit Issue` at the bottom

### Infrastructure ticket request

The bug tracker provides a private way to ask for account deletion. You can also request many account-related actions, up to and including deletion, by creating a ticket on the [infrastructure meta](https://git.resf.org/infrastructure/meta/issues) issue tracker. You can sign-in to the service with keycloak and your Rocky Account Services account, which can additionally help in account ownership validation. When creating a new issue, you can select the 'Account Requests - Personal Data Request' as the template.

### Email request

Click the [following link](mailto:identitymanagement@rockylinux.org?cc=infrastructure@rockylinux.org&subject=PDR%20Delete%20Request&body=%23%23%23%23%20Personal%20Data%20Request%20-%20Remove%20%23%23%23%23%0D%0A%0D%0AThis%20ticket%20is%20for%20the%20removal%20of%20my%20Personal%20Data%20that%20is%20attached%20to%20my%20(%7Buser%7D)%20account.%0D%0A%0D%0A%23%23%23%23%20Provide%20the%20following%20information%20%23%23%23%23%0D%0A%0D%0APlease%20fill%20in%20the%20following%20information%20to%20authorize%20the%20removal%20of%20your%20personal%20information.%0D%0A%0D%0AUsername%3A%20%3CUSER%3E%0D%0ADate%3A%20%3CDATE%3E%0D%0AEmail%20Address%3A%20%3CEMAIL%3E%0D%0A%0D%0A%23%23%23%23%20Information%20%23%23%23%23%0D%0A%0D%0ACreating%20this%20ticket%2FSending%20this%20email%2C%20I%20am%20aware%20of%20the%20following%3A%0D%0A%0D%0A*%20During%20processing%2C%20my%20account%20will%20be%20disabled%20and%20I%20will%20no%20longer%20be%20able%20to%20login%0D%0A*%20During%20processing%2C%20my%20account%20will%20be%20removed%20from%20all%20applicable%20groups%20in%20Account%20Services%0D%0A*%20During%20processing%2C%20my%20account%20will%20be%20set%20to%20%22private%22%20in%20Account%20Services%0D%0A*%20Signatures%2Fconsent%20to%20the%20agreements%20(such%20as%20the%20Rocky%20Open%20Source%20Contributor%20Agreement)%20will%20be%20remain%20for%20record%20keeping%0D%0A*%20The%20ticket%20filed%20for%20this%20request%20will%20be%20set%20to%20private%20and%20I%20will%20be%20notified%20of%20its%20closure.%0D%0A%0D%0A%23%23%23%23%20Comments%20%23%23%23%23%0D%0A%0D%0A(If%20you%20have%20additional%20comments%2C%20you%20may%20leave%20them%20here.)) to open an email draft to us to start the process.
