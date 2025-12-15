<cfscript>
	isGallery        = args.isGallery ?: false;
	availableWidgets = args.widgets   ?: QueryNew( "" );
	widgetGroups     = ListToArray( ListRemoveDuplicates( ValueList( availableWidgets.group ) ) );
	selectedWidget   = rc.widget ?: ( args.state.widget ?: "" );
	hasWidgetGroups  = isTrue( ArrayLen( widgetGroups ) );

	errorMessages    = {};
	validationResult = rc.validationResult ?: "";
	if ( !IsSimpleValue( validationResult ) ) {
		errorMessages = validationResult.getMessages();
	}

	hasError = StructKeyExists( errorMessages, "widget" );
</cfscript>

<cfoutput>
	<cfif hasError && Len( errorMessages.widget.message ?: "" )>
		<div class="alert alert-danger">
			<i class="fa fa-fw fa-exclamation-triangle"></i> #errorMessages.widget.message#
		</div>
	</cfif>

	<div class="admin-dashboards-widgets-wrapper">
		<div class="admin-dashboards-widgets-header">
			<input type="hidden" name="is_gallery"      value="#isGallery#" />
			<input type="hidden" name="selected_widget" value="#selectedWidget#" />

			<div class="widgets-search-container">
				<input type="text"
				       name="q"
				       class="widgets-search-bar"
				       placeholder="#translateResource( uri="webflow.adminDashboardsAddWidget:step.selectWidget.header.search.placeholder" )#"
				/>
				<i class="fa fa-fw fa-search widgets-search-icon"></i>
			</div>

			<cfif hasWidgetGroups>
				<div class="widgets-filter-container">
					<div class="widgets-filter-selected"></div>
				</div>
			</cfif>
		</div>

		<div class="admin-dashboards-widgets-message-container hide">
			<div class="alert alert-warning">
				<i class="fa fa-fw fa-exclamation-triangle"></i>
				#translateResource( uri="webflow.adminDashboardsAddWidget:step.selectWidget.no.widgets.msg" )#
			</div>
		</div>

		<div class="row admin-dashboards-widgets">
			<div class="col-md-#hasWidgetGroups ? "10" : "12"# admin-dashboards-widgets-container">
				#renderView( view="/admin/webflow/adminDashboardsAddWidget/_selectWidgetItems", args=args )#
			</div>

			<cfif hasWidgetGroups>
				<div class="col-md-2">
					#renderView( view="/admin/webflow/adminDashboardsAddWidget/_selectWidgetFilters", args={ widgetGroups=widgetGroups } )#
				</div>
			</cfif>
		</div>
	</div>
</cfoutput>