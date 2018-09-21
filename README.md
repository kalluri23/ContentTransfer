# Content Transfer #

# Contents #

* [Git Repo Guide](#git-repo-guide)
	
	* [CT_Current_Development_Branch](#ct_current_development_branch)
	
	* [Build Number And Build Date](#build-number-and-build-date)
	
	* [Emergency Release Branch](#emergency-release-branch)
	
	* [Create Branches](#create-banches)
	
	* [Tags](#tags)
	
	* [Scheme](#scheme)
	
* [Code Standard](#code-standard)
	
	* [General Rule](#general-rule)
	
	* [Objective-C](#objective-c)
	
	* [Swift](#swift)

* [QA Release Build Guide](#qa-release-build-guide)
	
	* [Jenkins QA Build](#jenkins-qa-build)
	
	* [MVM Content Transfer QA Build](#mvm-content-transfer-qa-build)

* [StandAlone Build Guide](#standalone-build-guide)

* [Framework Build Guide](#framework-build-guide)
	
	* [Build Framework Through Xcode](#build-framework-through-xcode)
	
	* [Build Framework Through Jenkins](#build-framework-through-jenkins)
	
	* [Framework Check List](#framework-check-list)

	* [Submit Framework Using Script](#submit-framework-using-script)
 
# Git Repo Guide #
## CT_Current_Development_Branch ##
Content transfer main repo for onestash is **CT_Current_Development_Branch**. Do not make direct code check in to this branch. This branch should always pick up the code from other branches through pull request.

After code freeze date, this branch should be "locked". If emergency fix needs to be added, make the change in **bugfix/dev_bug_fix** branch, and merge back to this branch. 

All other feature code should be merged into **feature/next_release_development_branch**, 
and after release tag is created, merge back to **CT_Current_Development_Branch**.

## Build Number And Build Date ##
Build/Date will be updated automatically through QA-Release/Store-Release Jenkins build or local Xcode.

Script will auto-increment build number(last digit) of the full-version string. Every time QA-Release/Store-Release build for CT_Current_Development_Branch, build number will be added one.

After release tag made, run updateVersion target in content transfer to update the version number and reset the build number to 0.
New version can be specified in UpdateVersion.plist in UpdateVersion target.

## Emergency Release Branch ##
If emergency is needed, make the change in **hotfix/emergency_fix_local** branch, and merge all hot fixes into **hotfix/emergency_release**. 

Jenkins will point to **hotfix/emergency_release** branch for emergency store submission.

## Create Branches ##
When creating branch in repo when needed, name the branch properly based on the content of the branch and give proper group, **bugfix/hotfix/feature**, etc.

All the branches created and code check in should be related to content transfer project, even local branch without remote. **Do not check in any uncertain POC code into any branch, no matter it's remoted or not**.

## Tags ##
When need to merge part of the code in some branch, or when need to mark the build, use tag. Name the tag using build number or content description. Do not remote tags except for previous two cases.

After each store submission, a tag needs to be created for last released version record.

## Scheme ##
During the development, make sure always using **Debug** scheme. Change to **QA-Release** when providing a build to QA. **Store-Release** will only be used for store submission.

# Code Standard #
## General Rule ##
* Symbol _'**{**'_ should be in same line for methods, and a space is needed between _'**{**'_ and clause keyword. 

**Expect:**

`func method() { ` or  `if (true) {`
	
* All the names using for methods or parameters should use 'Camel-Case'. 

**Expect:**

`longNameRule(type name);` 

**Not expect:**

`long_name_rule(type name)` or `longnamerule(type name)`

* Resolve as mush as possible warnings when coding, unless there is necessary warning added by developer.
* Group method definitions, and add marks through the file. Use `#pragma mark -` in **Objective-C** and `// MARK: -` in **Swift**.
* Documentation is required for all the public parameters and methods; Also add necessary documentation for private/inner methods and parameters that may cause confusion in the future.
* Properly tab the space for the code. In content transfer, all tabs will be **4 spaces**.

**Expect:**
````
if (true) {
	// code here...
}
````

**Not expect:**
````
if (true) { // code here... }
````
or 

````
if (true) {
// code here...
}
````

* Remove all temporary commented code, or the commented code you encouter during the programming.
* If using conditional operator, space is needed between each of the clause.

**Expect:**

`condition ? code1 : code 2;`

**Not Expect:**

`condition?code1:code2;`

## Objective-C ##
* When define method, space is needed after "-".

**Expect:**

`- (type)funcName:(type)param1 subName:(type)param2 {}`

**Not expect:**

`-(type)funcName:(type)param1 subName:(type)param2`
	
* No space is needed after the method return type. 

**Expect:** 
`- (void)method {` 

**Not expect:**
`- (void) method {` 
	
* Always use **YES** and **NO** for `BOOL` type.
* Always use `[instanceName methodName]` to call function in Objective-C.
* Always use `[[ClassName alloc] init]` to init an object in Objective-C. Don't use `[ClassName new]`.

## Swift ##
* Use delegate in extension when creating a class.

**Expect:**

````
class Sample: UIViewController {
    // properties
    // methods
}

extension Sample: Delegates {
    // delegate methods
}
````

**Not expect:**
````
class Sample: UIViewController, Delegates {
    // properties
    // methods
    // delegate methods
}

````

* All the parameters defined in current object should be called using self.

**Except:** `self.var = "value";`

**Not expect:** `var = "value";`


# QA Release Build Guide #
## Jenkins QA Build ##
QA release should be built through Jenkins. When building Jenkins, select **Build with Parameters**, then select branch name (generally it will be **CT_Current_Development_Branch**
) and build type **QA_Release**
, then check **ENTERPRISE_BUILD** option to build.

## MVM Content Transfer QA Build ##
For My Verizon content transfer framework, build framework through Xcode and replace (not merge) the framework file inside MVM build repo, and check into their desired branch. After merge back to dev, when MVM trigger a new build, it will automatically pick up content transfer.

Current MVM branch for content transfer is: **feature/enhancements**, create pull request back to **develop** branch.

For building framework, see [Framework Build Guide](#framework-build-guide)

# StandAlone Build Guide #
All the standalone build used for store submission should be built via Jenkins.
When building Jenkins build, simply follow QA release build step, only select **Store_Release** for build type. The archive file used for store submission will be generated under build folder of project repo.

The build and date of standalone are defined in info.plist file under VZ Transfer folder and project setting. Minimum verison is defined in **CTContentTransferSetting.h**.

# Framework Build Guide #
## Build Framework Through Xcode ##
When building framework via Xcode, if want to run framework and debug, select **contenttransfer** target and compile; If only need the framework file, select **contentTransferAggrergate** target and archive(no run option for this target).

No matter which way you choose to build, they all will generate a framework file in "contentTransfer_framework" folder, real file will be in the root project folder (copied through command line).

Each time creating a framework, simply update the modified date number identifier in the header comment of **CTFrameworkEntryPoint.h**, so framework date id will also be updated to know this framework is newly generated or not.

## Build Framework Through Jenkins ##
When build framework through Jenkins if needed, simply follow the step of [building standalone in Jenkins](#jenkins-qa-build), but before creating, also check **FrameworkRelease** option.
Framework will be generated under build folder of project repo.

## Framework Check List ##
Before building any framework, make sure build verison/date is changed to latest one. Version and date can be changed in info.plist file under contentTransferFramework folder.

## Submit Framework Using Script ##
Also instead of manually create framework and check in, script is support to do the same thing. Use script **cf(create framework)** to generate the framework by running **contentTransferAggergate** target and replace the old framework in MVM folder with the new one and auto check-into target branch.

Script will try to compile the code from the branch that is currently pointing at using **Store_Release** scheme. If do release, please make sure current branch is [CT_Current_Development_Branch](#ct_current_development_branch)

Script will be working after proper setup:
* Put the script in local machine. Add PATH to the URL that saved this script. When adding the PATH, go $HOME/.profile file (**If this file doesn't exist, just create one with same name**). Adding below code inside .profile

````
export PATH=$PATH:"folder_URL"

````

* Add project global environments for the script. Add below codes in ~/.profile file:

````
export CT_PATH="content_transfer_git_root_url"
export MVM_PATH="mvmrc_ios_git_root_url"
````

* Refresh the profile by running . ./.profile under $HOME folder.
* Start process by running `cf start` in commandline tool anywhere.
* Wait until the process done. You should see build date/number updated in content transfer current repo and framework checked into feature/enhancements in MVM.

If structure of content transfer git root or mvmrc_ios git root change, script code needs to be modified accordingly.
