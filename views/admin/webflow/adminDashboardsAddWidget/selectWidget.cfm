<cfscript>
	isGallery        = args.isGallery ?: false;
	availableWidgets = args.widgets   ?: QueryNew( "" );
	widgetGroups     = ListToArray( ListRemoveDuplicates( ValueList( availableWidgets.group ) ) );
	selectedWidget   = rc.widget ?: ( args.state.widget ?: "" );

	if ( ArrayLen( widgetGroups ) ) {
		ArrayPrepend( widgetGroups, "all" );
	}

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

		<cfif ArrayLen( widgetGroups )>
			<div class="widgets-filter-container">
				<select class="widgets-filter-select" name="widget_group">
					<cfloop array="#widgetGroups#" item="group">
						<option value="#group#">
							#translateResource( uri="admindashboards:group.#group#.label", defaultValue=UcFirst( group ) )#
						</option>
					</cfloop>
				</select>
			</div>
		</cfif>
	</div>

	<div class="admin-dashboards-widgets-message-container hide">
		<div class="alert alert-warning">
			<i class="fa fa-fw fa-exclamation-triangle"></i>
			#translateResource( uri="webflow.adminDashboardsAddWidget:step.selectWidget.no.widgets.msg" )#
		</div>
	</div>

	<div class="admin-dashboards-widgets-container">
		#renderView( view="/admin/webflow/adminDashboardsAddWidget/_selectWidgetItems", args=args )#
	</div>
</cfoutput>