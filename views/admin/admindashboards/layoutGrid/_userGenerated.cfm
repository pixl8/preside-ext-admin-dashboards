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
</cfscript>

<cfoutput>
	#renderView(
		  view="/admin/admindashboards/layoutGrid/_pageTitle"
		, args={
			  title             = ( prc.pageTitle         ?: "" )
			, subTitle          = ( prc.pageSubTitle      ?: "" )
			, icon              = ( prc.pageIcon          ?: "" )
			, pageHeaderButtons = ( prc.pageHeaderButtons ?: "" )
		}
	)#

	<div class="admin-dashboard-container" data-dashboard-id="#dashboardId#">
		<div class="grid-stack action-#action#" >
			<cfloop array="#widgets#" item="widget" index="i" >
				<cfset gridConfig = widget.gridConfig ?: {} >
				<div class="grid-stack-item"
					<cfloop collection="#gridConfig#" item="val" key="attr" >
						gs-#attr#="#val#"
					</cfloop>
				>
					<div class="grid-stack-item-content">
						#widget.html#
					</div>
				</div>
			</cfloop>
		</div>

		<cfif canEditDashboard AND isEditDashboardLayout >
			<div class="grid-stack-add">
				<a href="#addLink#" data-toggle="bootbox-modal" data-target="##add-widget-modal" data-buttons="cancel" data-modal-class="page-type-picker" title="#addTitle#">
					<!--- <i class="fa fa-solid fa-box"></i> --->
					<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50" fill="none">
						<path d="M47.122 0H2.87793C1.28292 0 0.104004 1.24827 0.104004 2.84327V11.165C0.104004 12.7601 1.35227 14.0083 2.94728 14.0083H47.122C48.6477 14.0083 49.9653 12.6907 49.9653 11.165V2.84327C49.896 1.31761 48.6477 0 47.122 0ZM48.509 11.165C48.509 11.9279 47.8155 12.6214 47.0527 12.6214H2.87793C2.04575 12.6214 1.42162 11.9972 1.42162 11.165V2.84327C1.49097 2.0111 2.1151 1.38696 2.87793 1.38696H47.0527C47.8155 1.38696 48.509 2.08044 48.509 2.84327V11.165Z" fill="black"/>
						<path d="M28.6754 18.4466H2.87794C1.28293 18.4466 0.034668 19.6949 0.034668 21.3592V47.0874C0.034668 48.6824 1.28293 50 2.87794 50H28.6754C30.2011 50 31.5187 48.6824 31.5187 47.0874V21.2899C31.5187 19.6949 30.2705 18.4466 28.6754 18.4466ZM30.1318 47.018C30.1318 47.8502 29.5076 48.5437 28.6754 48.5437H2.87794C2.04576 48.5437 1.42163 47.9195 1.42163 47.018V21.2899C1.42163 20.4577 2.04576 19.7642 2.87794 19.7642H28.6754C29.4383 19.7642 30.1318 20.4577 30.1318 21.2899V47.018Z" fill="black"/>
						<path d="M46.914 18.4466H39.4938C37.8988 18.4466 36.5812 19.7642 36.5812 21.3592V47.0874C36.5812 48.6824 37.8988 50 39.4938 50H46.914C48.5091 50 49.8267 48.6824 49.8267 47.0874V21.2899C49.8267 19.6949 48.5091 18.4466 46.914 18.4466ZM48.4397 47.018C48.4397 47.8502 47.7462 48.5437 46.914 48.5437H39.4938C38.6616 48.5437 37.9681 47.8502 37.9681 47.018V21.2899C37.9681 20.4577 38.6616 19.7642 39.4938 19.7642H46.914C47.7462 19.7642 48.4397 20.4577 48.4397 21.2899V47.018Z" fill="black"/>
					</svg>
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