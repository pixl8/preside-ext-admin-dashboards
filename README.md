# PresideCMS Extension: Admin Dashboards

This is an extension for PresideCMS that provides APIs and a methodolgy for creating user customizable dashboard interfaces in Preside admin.

## Installation

Install with:

```
box install preside-ext-admin-dashboards
```

## User stories

The following user stories describe the functionality of this extension:

* As an admin user, I want to be able to view a dashboard with multiple widgets so that I can get an overview of a particular data scenario(s)
* As an admin administrator, I want to be able to limit access to particular dashboard widgets so that I can protect sensitive data and functionality
* As an admin user, I want to be able to configure widgets and have my configuration persisted so that I can customize my view of a dashboard

### 3.0.0 Experimental

Version 3.0.0 release introduces some new undocumented features that will be fully released in a point release soon. The stories are:

* As an admin user, I want to be able to create and share my own dashboards in order to create user and business specific dashboard views
* As an admin user, I want to be able to insert a datatable widget into dashboards, configuring the source object, fields shown and optional filters on the data

## Rendering a dashboard

Admin dashboards are made up of "widgets" that a user can configure to show stats, summaries, etc. To render a dashboard, you can use the `renderAdminDashboard()` helper, providing an _arbitrary but unique_ dashboard ID that identifies a unique dashboard, an array of widget IDs and an optional column count (default 2, valid options are 1, 2, 3 or 4):

```cfc
#renderAdminDashboard( 
      dashboardId = "mainAdminDashboard"
    , widgets     = [ "latestNews", "topStories", "yourTasks" ]
    , columnCount = 3
)#
```

### Passing instance specific data

You may have a case where:

1. You have multiple instances of the same dashboard, but with different instance data
2. You have multiple instances of the same widget within your dashboard, but with different hard coded config values

For this you can use the `contextData` arg to `renderAdminDashboard` and/or individual widgets:

```cfc
// example 1
#renderAdminDashboard( 
      dashboardId = "mainAdminDashboard"
    , widgets     = [ "latestNews", "topStories", "yourTasks" ]
    , columnCount = 3
    , contextData = { recordId=prc.recordId }
)#

// example 2
#renderAdminDashboard( 
      dashboardId = "mainAdminDashboard"
    , columnCount = 3
    , widgets     = [ 
    	{ id="stats", contextData={ object="event" }, ajax=false, configInstanceId="event" }, 
    	{ id="stats", contextData={ object="news"  }, ajax=false, configInstanceId="news" }
      ]
)#
```

Notice how, in example 2, each widget is a `struct`. Widgets can either be passed as a simple string to represent the widget ID, or as a struct with the following keys:

* `id`: The widget ID
* `contextData`: Widget specific struct of data that will be passed to the widget render
* `ajax`: Whether or not to use ajax to render the widget (default true)
* `configInstanceId`: String to identify, along with the dashboard ID and user ID, a unique set of configuration options for the widget


## Creating dashboard widgets

An admin dashboard widget is created in three parts; a handler for rendering a widget and running any custom permissioning logic, an i18n properties file for labels and icons, and a preside form for providing any user editable config for the widget. 

For example, if you had a widget called `latestNews`, you would have the following files:

```
/i18n/admin/admindashboards/widget/latestNews.properties
/forms/admin/admindashboards/widget/latestNews.xml
/handlers/admin/admindashboards/widget/LatestNews.cfc
```

And they might look like this:

```properties
// /i18n/admin/admindashboards/widget/latestNews.properties
title=Latest news
description=See below for latest news articles for you to read.
iconClass=fa-newspaper orange

field.category.title=Category
```

```xml
// /forms/admin/admindashboards/widget/latestNews.xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="admin.admindashboards.widget.latestNews:">
	<tab id="default">
		<fieldset id="default" sortorder="10">
			<field name="category" control="objectpicker" object="category" />
		</fieldset>
	</tab>
</form>
```

```cfc
// /handlers/admin/admindashboards/widget/LatestNews.cfc
component {

	// You MUST implement a render() method with which to render
	// the content
	private string function render( event, rc, prc, args={} ) {
		args.latestNews = getModel( "newsService" ).getLatestNews( 
			  category = args.config.category ?: "" // args.config is the user configured config from the config form
			, featured = IsTrue( args.contextData.featured ?: "" ) // args.contextData is any data passed in renderAdminDashboard() call
		);
		return renderView( view="/admin/admindashboards/widgets/latestNews", args=args );
	}

	// An OPTIONAL permissions checking handler that returns true or false
	private boolean function hasPermission( event, rc, prc, args={} ) {
		return true;
	}

	// An OPTIONAL handler to render additional top right 'menu items' in the widget
	private string function additionalMenu( event, rc, prc, args={} ) {
		var addLink = event.buildAdminLink( objectName="news_item", operation="addRecord" );
		return '<a href="#addLink#"><i class="fa fa-fw fa-plus grey"></i></a>&nbsp; ';
	}
}
```


## What's next

We've created this extension with what we feel is the bare minimum functionality for a first release. Obvious features that are lacking:

* Ability for a dashboard to have _optional_ widgets that users can add to a dashboard if they want
* Ability for a dashboard user to drag items around and configure them the way they like
* Ability for a dashboard user to save a dashboard configuration and share it with other users

If you're keen on helping out with ideas or code, do get in touch!

