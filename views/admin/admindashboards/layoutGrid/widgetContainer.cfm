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
	editModalTitle = translateResource( uri="admindashboards:configure.widget.dialog.title", data=[ args.title ] );
	configureTitle = translateResource( uri="admindashboards:configure.widget.title" );
	moveTitle      = translateResource( uri="admindashboards:move.widget.title" );
	deletePrompt   = translateResource( uri="admindashboards:delete.widget.confirmation" );

	event.includeData( { "#args.instanceId#"=args.contextData } );
</cfscript>

<cfoutput>
		<div class="widget-box admin-dashboard-widget"
				data-ajax               = "#IsTrue( args.ajax )#"
				data-ajax-callback      = "#args.ajaxCallback#"
				data-widget-id          = "#args.widgetId#"
				data-instance-id        = "#args.instanceId#"
				data-has-config         = "#args.hasConfig#"
				data-config-modal-title = "#HtmlEditFormat( editModalTitle )#"
				data-config-instance-id = "#args.configInstanceId#">
			<div class="widget-header">
				<h4 class="widget-title">
					<!---
						<cfif args.icon.len()>
							<i class="fa fa-fw #args.icon#"></i>
						</cfif>
					--->
					<span>#args.title#</span>
				</h4>
				<div class="widget-toolbar">
					#args.additionalMenu#
					<a class="widget-draggable-handle" href="##" title="#htmlEditFormat( moveTitle )#"><i class="fa fa-fw fa-arrows"></i></a>
					<cfif args.hasConfig>
						<a class="widget-configuration-link" href="##" title="#htmlEditFormat( configureTitle )#"><i class="fa fa-fw fa-pencil"></i></a>
					</cfif>
					<cfif args.canDeleteWidget>
						<a class="widget-delete-link" title="#htmlEditFormat( deletePrompt )#" href="#event.buildAdminLink( linkTo="adminDashboards.deleteWidget", queryString="dashboardId=#args.dashboardId#&instanceId=#args.configInstanceId#" )#"><i class="fa fa-fw fa-trash"></i></a>
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
