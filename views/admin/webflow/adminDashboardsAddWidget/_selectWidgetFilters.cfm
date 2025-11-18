<cfscript>
	widgetGroups = args.widgetGroups ?: [];
</cfscript>

<cfoutput>
	<cfif ArrayLen( widgetGroups )>
		<div class="admin-dashboards-widgets-filter form-group">
			<h4 class="widgets-filter-title">
				#translateResource( uri="webflow.adminDashboardsAddWidget:step.selectWidget.filters.group.label" )#
			</h4>

			<cfloop array="#widgetGroups#" item="group">
				<cfset groupLabel = translateResource( uri="admindashboards:group.#group#.label", defaultValue=UcFirst( group ) ) />

				<div class="form-field">
					<div class="checkbox">
						<input type="checkbox"
						       name="group"
						       id="group-#group#"
						       value="#group#"
						       data-label="#groupLabel#"
						/>
						<label for="group-#group#">
							#groupLabel#
						</label>
					</div>
				</div>
			</cfloop>
		</div>
	</cfif>
</cfoutput>