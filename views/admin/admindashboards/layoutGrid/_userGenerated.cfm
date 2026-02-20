<cfscript>
	dashboardId      = args.id           ?: "";
	widgets          = args.widgets      ?: [];
	canEditDashboard = isTrue( args.canEdit ?: "" );

	addTitle = translateResource( "preside-objects.admin_dashboard:widget.add.btn" );
	addLink  = event.buildAdminLink( linkTo="adminDashboards.widgetDialog", queryString="dashboard=#dashboardId#" );

	event.include( "/js/admin/specific/admindashboards/gridlayout/" )
		 .include( "/css/admin/specific/admindashboards/gridlayout/" );

	action = LCase( ListLast( rc.event ?: "", "." ) );

	isViewRecord          = ( action == "viewrecord" );
	isEditDashboardLayout = ( action == "editdashboardlayout" );

	event.includeData( { dashboard_action=action } )

	includePageHeader = IsTrue( args.includePageHeader ?:  "" );
</cfscript>

<cfoutput>
	<cfif includePageHeader>
		#renderView(
			  view = "/admin/admindashboards/layoutGrid/_pageTitle"
			, args = {
				  title                 = ( prc.pageTitle             ?: "" )
				, subTitle              = ( prc.pageSubTitle          ?: "" )
				, icon                  = ( prc.pageIcon              ?: "" )
				, pageHeaderButtons     = ( prc.pageHeaderButtons     ?: "" )
				, showDashboardSelector = ( prc.showDashboardSelector ?: URL.showDashboardSelector ?: false ) // Static way (URL scope), please update accordingly in the proper BE implementation
			}
		)#
	</cfif>

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