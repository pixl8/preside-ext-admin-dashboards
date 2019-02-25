<cfparam name="args.icon"             default="" />
<cfparam name="args.title"            default="" />
<cfparam name="args.description"      default="" />
<cfparam name="args.widgetId"         default="" />
<cfparam name="args.hasConfig"        default="false" />
<cfparam name="args.columnSize"       default="6" />
<cfparam name="args.contextData"      default="#StructNew()#" />
<cfparam name="args.instanceId"       default="#CreateUUId()#" />
<cfparam name="args.configInstanceId" default="" />
<cfparam name="args.additionalMenu"   default="" />

<cfscript>
	editModalTitle = translateResource( uri="admindashboards:configure.widget.dialog.title", data=[ args.title ] );

	event.includeData( { "#args.instanceId#"=args.contextData } );
</cfscript>

<cfoutput>
	<div class="col-md-#args.columnSize#">
		<div class="widget-box admin-dashboard-widget" data-widget-id="#args.widgetId#" data-instance-id="#args.instanceId#" data-has-config="#args.hasConfig#" data-config-modal-title="#HtmlEditFormat( editModalTitle )#" data-config-instance-id="#args.configInstanceId#">
			<div class="widget-header">
				<h4 class="widget-title lighter smaller">
					<cfif args.icon.len()>
						<i class="fa fa-fw #args.icon#"></i>
					</cfif>
					#args.title#
				</h4>
				<cfif args.hasConfig>
					<div class="widget-toolbar">
						#args.additionalMenu#
						<a class="widget-configuration-link grey" href="##"><i class="fa fa-fw fa-cog"></i></a>
					</div>
				</cfif>
			</div>

			<div class="widget-body">
				<div class="widget-main padding-20">
					<cfif args.description.len()>
						<p><em class="grey">#args.description#</em></p>
						<hr>
					</cfif>

					<div class="widget-dynamic-content">
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>