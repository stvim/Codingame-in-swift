# ``CodingameTemplate``

## Overview

How to use this template to create a new codingame subproject to work on a new challenge/puzzle/botbattle/etc

## Topics

### Actions to prepare a new working place

- In Project, create a new Target named XXX, and *Include XCTests*
- In its properties, add the framework CodingameCommon in the 'framework and libraries'
- Move the 2 groups XXX and XXXTests into an appropriate parent Group
- In XXX group, create a swift code file named exerciceAAA
- Copy and paste the content of CodingameTemplate/Exercice1 into this file
- In XXXTests group, create a swift code file named exerciceAAATests and a exerciceAAAData01 empty file
- Copy and paste the content of CodingameTemplateTests/Exercice1Tests into the XXXTests/exerciceAAATests, then rename import, class name and data filename inside the code (first lines)


