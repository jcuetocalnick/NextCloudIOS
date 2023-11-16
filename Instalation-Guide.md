Our project goal was to customize the Nextcloud App in the IOS plataform.

We forked from the origional nextcloud github repo -> https://github.com/nextcloud/ios.git
All of our project "Customizing the NextCloud IOS app " is sitting in this github repo -> https://github.com/jcuetocalnick/NextCloudIOS.git
The git repo's branch that conatins all of our latest code is "theming_nextcloud" , all of the other testing branches should have been deleted but if for any reason they still show up when you clone please disregard .

"Steps to correctly clone our project and run it locally in your device "
-Download Carthage Dependency here → [Releases · Carthage/Carthage](https://github.com/Carthage/Carthage/releases)


-Install Brew in your machine → /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) "‌")"

-brew install carthage

-cd into where you have your project

brew install carthage
brew link carthage
brew link --overwrite carthage
carthage update --use-xcframeworks --platform iOS
-After these steps errors should go away but may come back because we are missing a file that we need in our project .

-Download file from here ->https://github.com/firebase/quickstart-ios/blob/master/mock-GoogleService-Info.plistConnect your Github account (where it says Download raw file)

-That file just drop it inside your project folder

-Rename it (keep same name erase “Mock” from it) should look like this → GoogleService-Info.plist

-Go into your XCode and on the very top option select Xcode → Settings → Locations → and click on Command Line Tools (there should only be one option there click on it and enter your password)

-Go back to your terminal and run the following command

carthage update --cache-builds --use-xcframeworks --platform ios

-Run your project !

‌

and your project should now work without any issues :))))
