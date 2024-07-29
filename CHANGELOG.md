# Changelog

## v3.0.6

* [DASH-26](https://projects.pixl8.london/browse/DASH-26) - (p1) There is no Granular permissions for Admin Dashboards
* [DASH-27](https://projects.pixl8.london/browse/DASH-27) - (p1) Infinite load on keyword search on admin dashboard list

## v3.0.5

* Update build version generator

## v3.0.4

* Fix minor admin permission checking issues

## v3.0.3

* Fix inability to exclude dashboard widget by some criteria (i.e. when feature disabled)

## v3.0.2

* Fix issue where super users could not delete dashboards owned by other users

## v3.0.1

* Limit dynamic widget titles to 50 chars

## v3.0.0

Experimental release giving two new features

* User configurable and sharable dashboards
* New widget to share a user configurable datatable in a dashboard

Further notes and documentation on these super cool features to come in a stable point release.

## v2.0.7

* Add interception point for rendering dashboard widgets

## v2.0.6

* Move build pipeline to Github Actions

## v2.0.5

* Version bump

## v2.0.4

* Fix Travis build

## v2.0.3

* Add German translations

## v2.0.2

* Fix [#1](https://github.com/pixl8/preside-ext-admin-dashboards/issues/1): additional menu would not show unless widget had config

## v2.0.1

* Ensure config is correctly passed to render content

## v2.0.0

* Add documentation directly to the readme

## v1.5.0

* Add ajax option to widgets so that they can be rendered inline if needed (useful for things that call datatables, etc)
* Add ability to add additional menu rendering for widgets
* Allow developers to specify specific 'config instance' ids to define how configuration should be shared across multiple instances of a dashboard
* Ensure that instances of widget configuration are unique to the context data passed to the dashboard/widget. Means you can have multiple instances of same widget on one dashboard but with different context input data and unique additional configuration
* Provide a mechanism for passing contextual data to a dashboard / widget within a dashboard

## v1.0.1

* Add ability to set number of columns in a dashboard

## v1.0.0

* Initial working commit
