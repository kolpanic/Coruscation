Coruscation
===========

Coruscation checks all installed Sparkle-enabled apps for updates. It's released under a BSD license.

It uses private Launch Services API to list all apps, checks each found app's bundle info dictionary for SUFeedURL, then instantiates a SUUpdater to do the check. It uses a customized Sparkle FW (forked at GitHub — use the included get_sparkle.sh shell script to clone it next to Coruscation) to suppress some error alerts (among other things; see Read Me.txt in the project for details). Apps with updates are presented in a NSCollectionView from which they can be launched to perfom the actual update. Updates can be run automatically either weekly or monthly.

A pre-built version is available [here](https://github.com/kolpanic/Coruscation/releases/1.0/1095/coruscation.zip).

Coruscation uses a [customized fork of Sparkle](http://github.com/kolpanic/Sparkle/). It's included as a git submodule.
