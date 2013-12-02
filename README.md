Coruscation
===========

Coruscation checks all installed Sparkle-enabled apps for updates. It's released under a BSD license.

It uses private Launch Services API to list all apps, checks each found app's bundle info dictionary for SUFeedURL, then instantiates a SUUpdater to do the check. It uses a customized Sparkle FW (forked at GitHub — use the included get_sparkle.sh shell script to clone it next to Coruscation) to suppress some error alerts (among other things; see Read Me.txt in the project for details). Apps with updates are presented in a NSCollectionView from which they can be launched to perfom the actual update.

A pre-built version is available on the Releases tab.

Coruscation uses a [customized fork of Sparkle](http://github.com/kolpanic/Sparkle/). It's included as a git submodule.