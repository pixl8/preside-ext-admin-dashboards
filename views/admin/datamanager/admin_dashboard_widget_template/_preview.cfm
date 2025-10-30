<cfscript>
	templateConfig   = args.templateConfig     ?: {};
	templateWidget   = templateConfig.widgetId ?: "";
	templateViewlet  = "admin.admindashboards.widget.#templateWidget#.render";
	templateIncludes = "admin.admindashboards.widget.#templateWidget#.ajaxIncludes";

	widgetTitle = Trim( args.record.title ?: "" );

	if ( getController().viewletExists( templateIncludes ) ) {
		renderViewlet( event=templateIncludes, args={} );
	}
</cfscript>

<cfoutput>
	<cfif !StructIsEmpty( templateConfig ) && Len( templateWidget ) && getController().viewletExists( templateViewlet )>
		<div class="container">
			<div class="col-md-6 col-md-offset-3">
				<div class="widget-box admin-dashboard-widget">
					<div class="widget-header">
						<h4 class="widget-title lighter smaller">
							<span>#widgetTitle#</span>
						</h4>
					</div>

					<div class="widget-body">
						<div class="widget-main padding-20">
							<div class="widget-dynamic-content">
								#renderViewlet( event=templateViewlet, args={ config=templateConfig } )#
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</cfif>
</cfoutput>