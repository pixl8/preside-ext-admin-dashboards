<cfscript>
	dashboardId      = args.dashboardId  ?: args.id ?: "";
	widgets          = args.widgets      ?: [];
	canEditDashboard = isTrue( args.canEdit ?: "" );

	addTitle = translateResource( "preside-objects.admin_dashboard:widget.add.btn" );
	addQs    = "dashboard=#dashboardId#";

	if ( Len( Trim( args.inlineToolbarPostAddDashboardUrl ?: "" ) ) ) {
		addQs &= "&post_add_dashboard_url=#UrlEncodedFormat( args.inlineToolbarPostAddDashboardUrl )#";
	}

	addLink  = event.buildAdminLink( linkTo="adminDashboards.widgetDialog", queryString=addQs );

	event.include( "/js/admin/specific/admindashboards/gridlayout/" )
		 .include( "/css/admin/specific/admindashboards/gridlayout/" );

	action = LCase( args.dashboardLayoutAction ?: "" );

	if ( !Len( action ) ) {
		action = LCase( ListLast( rc.event ?: "", "." ) );

		if ( action != "editdashboardlayout" && action != "viewrecord" ) {
			action = "viewrecord";
		}
	}

	isViewRecord          = ( action == "viewrecord" );
	isEditDashboardLayout = ( action == "editdashboardlayout" );

	event.includeData( { dashboard_action=action } )

	includePageHeader = isTrue( args.includePageHeader ?:  "" );
	hasContextData    = isTrue( args.hasContextData ?: "" );
	nonContextWidgets = args.nonContextWidgets ?: [];

	args.pageHeaderButtons = args.pageHeaderButtons ?: renderView( view="/admin/admindashboards/layoutGrid/_inlineDashboardEditToolbar", args=args );
</cfscript>

<cfoutput>
	<cfif hasContextData and ArrayLen( nonContextWidgets )>
		<div class="alert alert-warning no-margin-bottom">
			<p><i class="fa fa-fw fa-exclamation-triangle"></i> #translateResource( uri="admindashboards:non.contextual.widgets.message" )#</p>
			<ul>
				<cfloop array="#nonContextWidgets#" item="nonContextWidget">
					<li>#nonContextWidget.title#</li>
				</cfloop>
			</ul>
		</div>
	</cfif>

	#renderViewlet( event="admin.adminDashboards.renderDashboardHeader", args=args )#

	<div class="admin-dashboard-container" data-dashboard-id="#dashboardId#">

		<cfif canEditDashboard && isEditDashboardLayout>
			<div class="grid-stack-add">
				<a href="#addLink#" data-toggle="bootbox-modal" data-buttons="cancel" data-modal-class="full-screen-dialog" data-title="#HtmlEditFormat( addTitle )#">
					<i class="fa fa-fw fa-plus"></i>
					#addTitle#
				</a>
			</div>
		</cfif>

		<div class="grid-stack action-#action#" >
			<cfloop array="#widgets#" item="widget" index="i">
				<cfif isEditDashboardLayout >
					<cfset gridConfig = widget.editTempGridConfig ?: {} >
				<cfelse>
					<cfset gridConfig = widget.gridConfig ?: {} >
				</cfif>
				<div class="grid-stack-item"
					<cfloop collection="#gridConfig#" item="val" key="attr">
						gs-#attr#="#val#"
					</cfloop>
				>
					<div class="grid-stack-item-content">
						#widget.html#
					</div>
				</div>
			</cfloop>
		</div>

		<script type="text/template" class="error-template">
			<p class="alert alert-error">
				<i class="fa fa-fw fa-exclamation-triangle"></i>
				#translateResource( "admindashboards:widget.failed.to.load.message" )#
			</p>
		</script>
	</div>
</cfoutput>