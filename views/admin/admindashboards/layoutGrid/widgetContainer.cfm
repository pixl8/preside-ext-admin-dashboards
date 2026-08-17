<cfparam name="args.icon"             default="" />
<cfparam name="args.title"            default="" />
<cfparam name="args.description"      default="" />
<cfparam name="args.widgetId"         default="" />
<cfparam name="args.hasConfig"        default="false" />
<cfparam name="args.canDeleteWidget"  default="false" />
<cfparam name="args.hasConfig"        default="false" />
<cfparam name="args.columnSize"       default="6" />
<cfparam name="args.contextData"      default="#StructNew()#" />
<cfparam name="args.instanceId"       default="#CreateUUId()#" />
<cfparam name="args.configInstanceId" default="" />
<cfparam name="args.dashboardId"      default="" />
<cfparam name="args.additionalMenu"   default="" />
<cfparam name="args.deleteMenu"       default="" />
<cfparam name="args.ajax"             default="true" />
<cfparam name="args.ajaxCallback"     default="" />
<cfparam name="args.userGeneratedDashboard" default="false" />

<cfscript>
	editModalTitle    = translateResource( uri="admindashboards:configure.widget.dialog.title", data=[ args.title ] );
	configureTitle    = translateResource( uri="admindashboards:configure.widget.title" );
	moveTitle         = translateResource( uri="admindashboards:move.widget.title" );
	deletePrompt      = translateResource( uri="admindashboards:delete.widget.confirmation" );
	exportConfigTitle = translateResource( uri="admindashboards:export.widget.title" );
	exportModalTitle  = translateResource( uri="admindashboards:export.widget.dialog.title", data=[ args.title ] );

	event.includeData( { "#args.instanceId#"=args.contextData } );

	action = LCase( args.dashboardLayoutAction ?: "" );

	if ( !Len( action ) ) {
		action = LCase( ListLast( rc.event ?: "", "." ) );
	}

	if ( action != "editdashboardlayout" && action != "viewrecord" ) {
		action = "viewrecord";
	}

	isViewRecord          = ( action == "viewrecord" );
	isEditDashboardLayout = ( action == "editdashboardlayout" );
	hasToolbarActions     = isEditDashboardLayout || Len( Trim( args.additionalMenu ) );

	deleteQs = "dashboardId=#args.dashboardId#&instanceId=#args.configInstanceId#";

	if ( Len( Trim( args.deleteWidgetReturnUrl ?: "" ) ) ) {
		deleteQs &= "&returnUrl=#UrlEncodedFormat( args.deleteWidgetReturnUrl )#";
	}
</cfscript>

<cfoutput>
		<div class="widget-box admin-dashboard-widget"
				data-ajax               = "#IsTrue( args.ajax )#"
				data-ajax-callback      = "#args.ajaxCallback#"
				data-widget-id          = "#args.widgetId#"
				data-instance-id        = "#args.instanceId#"
				data-has-config         = "#args.hasConfig#"
				data-config-modal-title = "#HtmlEditFormat( editModalTitle )#"
				data-export-modal-title = "#HtmlEditFormat( exportModalTitle )#"
				data-config-instance-id = "#args.configInstanceId#">
			<div class="widget-header">
				<h4 class="widget-title">
					<span>#args.title#</span>
				</h4>
				<div class="widget-toolbar<cfif hasToolbarActions> has-actions</cfif>">
					<cfif isEditDashboardLayout>
						<a class="widget-draggable-handle" title="#HtmlEditFormat( moveTitle )#"><i class="fa fa-fw fa-arrows"></i></a>
						<cfif args.hasConfig>
							<a class="widget-export-config-link" href="##" title="#HtmlEditFormat( exportConfigTitle )#"><i class="fa fa-fw fa-share"></i></a>
							<a class="widget-configuration-link" href="##" title="#HtmlEditFormat( configureTitle )#"><i class="fa fa-fw fa-pencil"></i></a>
						</cfif>
						<cfif args.canDeleteWidget>
							<a class="widget-delete-link" title="#HtmlEditFormat( deletePrompt )#" href="#event.buildAdminLink( linkTo="adminDashboards.deleteWidget", queryString=deleteQs )#"><i class="fa fa-fw fa-trash"></i></a>
						</cfif>
					<cfelseif Len( Trim( args.additionalMenu ) )>
						#args.additionalMenu#
					</cfif>
				</div>
			</div>

			<div class="widget-body">
				<div class="widget-main">
					<cfif args.description.len() && !args.userGeneratedDashboard>
						<p><em class="grey">#args.description#</em></p>
						<hr>
					</cfif>

					<div class="widget-dynamic-content">
						<cfif !args.ajax>
							#args.content#
						</cfif>
					</div>
				</div>
			</div>
		</div>
</cfoutput>
