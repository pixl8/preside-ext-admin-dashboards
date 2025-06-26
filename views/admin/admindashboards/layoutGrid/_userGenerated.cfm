<cfscript>
	dashboardId      = args.id           ?: "";
	widgets          = args.widgets      ?: [];
	canEditDashboard = isTrue( args.canEdit ?: "" );

	addTitle = translateResource( "preside-objects.admin_dashboard:widget.add.btn" );
	addLink  = event.buildAdminLink( linkTo="adminDashboards.widgetDialog", queryString="dashboard=#dashboardId#" );

	event.include( "/js/admin/specific/admindashboards/gridlayout/" )
		 .include( "/css/admin/specific/admindashboards/gridlayout/" );
</cfscript>

<cfoutput>
	<div class="admin-dashboard-container" data-dashboard-id="#dashboardId#">
		<div class="grid-stack">
			<cfloop array="#widgets#" item="widget" index="i" >
				<div class="grid-stack-item" <cfif i == 2 >gs-w="2" gs-h="2"</cfif> <cfif i == 4 >gs-h="2"</cfif> <cfif i == 6 >gs-h="2" gs-w="2" gs-x="2" gs-y="3"</cfif>>
					<div class="grid-stack-item-content">
						#widget#
					</div>
				</div>
			</cfloop>
		</div>

		<cfif canEditDashboard>
			<div class="grid-stack-add">
				<a href="#addLink#" data-toggle="bootbox-modal" data-target="##add-widget-modal" data-buttons="cancel" data-modal-class="page-type-picker" title="#addTitle#">
					<i class="fa fa-solid fa-box"></i>
					#addTitle#
				</a>
			</div>
		</cfif>

		<script type="text/template" class="error-template">
			<p class="alert alert-error">
				<i class="fa fa-fw fa-exclamation-triangle"></i>
				#translateResource( "admindashboards:widget.failed.to.load.message" )#
			</p>
		</script>
	</div>
</cfoutput>