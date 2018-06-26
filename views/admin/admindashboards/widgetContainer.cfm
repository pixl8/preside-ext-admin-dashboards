<cfparam name="args.icon"        default="" />
<cfparam name="args.title"       default="" />
<cfparam name="args.description" default="" />
<cfparam name="args.widgetId"    default="" />
<cfparam name="args.hasConfig"   default="false" />

<cfscript>
	editModalTitle = translateResource( uri="admindashboards:configure.widget.dialog.title", data=[ args.title ] );
</cfscript>

<cfoutput>
	<div class="col-md-4">
		<div class="widget-box admin-dashboard-widget" data-widget-id="#args.widgetId#" data-has-config="#args.hasConfig#" data-config-modal-title="#HtmlEditFormat( editModalTitle )#">
			<div class="widget-header">
				<h4 class="widget-title lighter smaller">
					<cfif args.icon.len()>
						<i class="fa fa-fw #args.icon#"></i>
					</cfif>
					#args.title#
				</h4>
				<cfif args.hasConfig>
					<div class="widget-toolbar">
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