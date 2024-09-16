# mooseapp-code-plugin aka "Geronimo"

When MooseApps are extended with new MooseObjects, e.g. in workgroups, the need quickly arises to be able to transfer this functionality to other MooseApps as a plug-in. Preferably without having to manually copy and adapt many code files. Furthermore, it is often good if there is independent source code management or versioning. The idea is to realise such code plug-ins for MooseApps as git submodules.

This repository demonstrates how to realize a 'contrib' code plugin for MooseApps derived from [Moose](https://mooseframework.inl.gov).
For this purpose, this repository contains the needed makefile ([codeplugin.mk](codeplugin.mk)), the user setup guide (see below) and some notes for implementers (also see below).


## Setup for Users

If you want to use this code-plugin in your MooseApp, follow these steps:

- Clone this repository as git-submodule in a sub-folder in `./contrib/` of your MooseApp

- In your MooseApp `Makefile`, insert the following line **directly above** the line `include $(FRAMEWORK_DIR)/app.mk` (if you have multiple code plugins, you need this line only once):
  ```
  include $(wildcard $(CURDIR)/contrib/*/codeplugin.mk)
  ```

- Compile your MooseApp.


## For Implementers

If you want to offer a Moose code plugin for others to use, follow these steps:

- Create a new repository using this template or fork this repository.

- In your fork:

  - Do not delete, move, or rename `codeplugin.mk` and `codeplugin.template.mk`.

  - Add your code my means of .C-files (`src` folder) and .h-files (`include` folder). Please see an example Moose function `StepFunction` provided (which can be deleted).

  - Please note, that the call to `registerMooseObject` in your MooseObjects may use the global constant `MOOSEAPPNAME` (which is automatically set to the name of the user's MooseApp). See [StepFunction.C](src/StepFunction.C) for an example.

  - Edit this README.md with a meaningful description and all details desired. You may delete this section ("For Implementers") but leave "Setup for Users".

  - Test your code. The best way to do this is to provide tests via the `test` folder. These tests can be executed using the `./run_tests` script (after compiling your app).

  - Commit your changes.

- Provide the URL of your git-repository to your users so they can clone your repository as a submodule (see "Setup for Users").


## About the naming

[Moose](https://mooseframework.inl.gov) [asks](https://mooseframework.inl.gov/getting_started/new_users.html) that MooseApps are named after animals. This repository is by no means a full-grown MooseApp, but a plugin. Therefore, the aka name ‘Geronimo’ was chosen for this repository in reference to a single beaver of the same name that was used for parachute testing in northwest Idaho ([Wikipedia](https://en.wikipedia.org/wiki/Beaver_drop)). The idea is that you can simply and safely drop Geronimo into your application.
