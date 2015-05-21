# Awful Tower

## About

This project started off as a game, with a level editor as part of the game.
I realized that there is no way I would have enough time to build the game, but
the level editor was coming along nicely. I decided to just scrap the
game for the time being and release an awesome level editor.

My goal is to create a lightweight map editor, that allows multiple people to
collaborate on maps at the **same time**.

## Setup
This project requires you to have **Node** and npm installed. Then you will need to
install:

 * [MongoDB](https://www.mongodb.org/)
 * [Gulp](http://gulpjs.com/ ) - `npm install -g gulp`
 * [Coffeescript](http://coffeescript.org/) - `npm install -g coffee-script`

Clone the repo, build it, and go!

```
git clone https://github.com/toadums/awfultower
cd awfultower
npm install && bower install
gulp
```

## Its not quite done yet..

I haven't found the time to finish this project yet. Some fairly basic things
are missing, and the user experience is non-existant ^_^

The two deal breakers are that not finished yet are: exporting maps to JSON,
and importing tilesheets - this was the last thing I worked on, so it is kinda started.

Here is what you need to do to start making a level:

```
Go to localhost:3000/login
create an account
signin

import a tilesheet (must be 32x32 with no padding between cells).
  You can download level3.png from the assets and use that...its a tad off, but will give you the idea

create a new map
  hit the + in the bottom left

Enjoy drawing, and not being able to export your tilemap D:
```
