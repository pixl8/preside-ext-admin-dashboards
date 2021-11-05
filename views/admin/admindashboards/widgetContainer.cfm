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
	editModalTitle  = translateResource( uri="admindashboards:configure.widget.dialog.title", data=[ args.title ] );
	configureTitle  = translateResource( uri="admindashboards:configure.widget.title" );
	fullscreenTitle = translateResource( uri="admindashboards:fullscreen.widget.title" );
	deletePrompt    = translateResource( uri="admindashboards:delete.widget.confirmation" );

	event.includeData( { "#args.instanceId#"=args.contextData } );
</cfscript>

<cfoutput>
	<cfif !args.userGeneratedDashboard>
		<div class="col-md-#args.columnSize#">
	</cfif>
		<div class="widget-box admin-dashboard-widget"
				data-ajax               = "#IsTrue( args.ajax )#"
				data-ajax-callback      = "#args.ajaxCallback#"
				data-widget-id          = "#args.widgetId#"
				data-instance-id        = "#args.instanceId#"
				data-has-config         = "#args.hasConfig#"
				data-config-modal-title = "#HtmlEditFormat( editModalTitle )#"
				data-config-instance-id = "#args.configInstanceId#">
			<div class="widget-header">
				<h4 class="widget-title lighter smaller">
					<cfif args.icon.len()>
						<i class="fa fa-fw #args.icon#"></i>
					</cfif>
					<span>#args.title#</span>
				</h4>
				<div class="widget-toolbar">
					#args.additionalMenu#
					<a class="widget-fullscreen-link orange" href="##" title="#htmlEditFormat( fullscreenTitle )#"><i class="fa fa-fw fa-expand"></i></a>
					<cfif args.hasConfig>
						<a class="widget-configuration-link grey" href="##" title="#htmlEditFormat( configureTitle )#"><i class="fa fa-fw fa-cog"></i></a>
					</cfif>
					<cfif args.canDeleteWidget>
						<a class="widget-delete-link red" title="#htmlEditFormat( deletePrompt )#" href="#event.buildAdminLink( linkTo="adminDashboards.deleteWidget", queryString="dashboardId=#args.dashboardId#&instanceId=#args.configInstanceId#" )#"><i class="fa fa-fw fa-trash"></i></a>
					</cfif>
				</div>
			</div>

			<div class="widget-body">
				<div class="widget-main padding-20">
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
	<cfif !args.userGeneratedDashboard>
		</div>
	</cfif>
</cfoutput>
