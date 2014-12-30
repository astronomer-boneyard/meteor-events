meteor-usercycle
==============

Push events automatically to Segment.com from your Meteor app.

This package will observe your signups and IronRouter route hits, and
effortlessly push events to your Segment account.

## Installation

`meteor add usercycle:usercycle`

## Usage

Add a "public.usercycle" node to your [Meteor.settings](http://docs.meteor.com/#/full/meteor_settings) JSON.

```
{
  "public": {
    "usercycle": {
      "debug": true,
      "segment": {
        "writeKey": "xxxxxxxx"
      },
      "signup": {
        "name": "Signed Up"
      },
      "retention": {
        "name": "Viewed Dashboard",
        "routes": "dashboard"
      }
    }
  }
}
```

## Sample Scripts

This package can be used to support your [USERcycle](https://usercycle.com) account,
which requires you to get a [Keen IO](https://keen.io/) database setup with your
historical data. You can use the scripts below to quickly populate your Keen IO
database with your Meteor app's production data.

### 1. Export Users from Mongo

Modify the code below with your production Mongo's port, host, username, password, and database name. We're simply exporting the user id's and createdAt fields.

```
mongoexport --port 10059 --host candidate.15.mongolayer.com \
-u appProd -p myPassword --db appProd --collection users \
--csv --fields _id,createdAt --out users.csv
```

### 2. Import "Signed Up" events into Keen IO

* Install the keen-cli npm package
* Edit the CSV you created in step one — change column names:
  * `_id` to "user.userId"
  * `created_at` to "keen.timestamp"
* Modify the command below to include your Keen project id and write key:

```
keen events:add -c "Signed Up" -f users.csv --csv -p myPublicKey -w myWriteKey
```

### 3. Export retention event from Mongo

There is probably one collection that is most important for your users to create on a regular basis, in order to be considered an active user. Hopefully you've been recording a userId and createdAt date for the collection, otherwise you're out of luck on this step.

Modify the code below with your production Mongo's port, host, username, password, and database name.

```
mongoexport --port 10059 --host candidate.15.mongolayer.com \
-u appProd -p myPassword --db appProd --collection tweets \
--csv --fields userId,createdAt --out tweets.csv
```

### 4. Import retention event into Keen IO

* Edit the CSV you created in step one — change column names:
  * `userId` to "user.userId"
  * `created_at` to "keen.timestamp"
* Modify the command below to include your Keen project id and write key:

```
keen events:add -c "Tweeted" -f tweets.csv --csv -p myPublicKey -w myWriteKey
```
