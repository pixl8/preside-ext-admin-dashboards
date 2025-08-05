<cfscript>
	grouped           = prc.grouped    ?: {};
	groups            = prc.groups ?: StructKeyArray( grouped );
	selectedgroup     = Len( rc.group ?: "" ) ? rc.group : ( ArrayLen( groups ) ? ArrayFirst( groups ) : "" );
	widgetQueryFields = "id,title,group,description,icon,isTemplate,config";
</cfscript>

<cfoutput>
	<cfif ArrayLen( groups )>
		<div class="row admin-dashboard-widgets-container">
			<div class="col-sm-3">
				<div class="widget-group-menu">
					<ul class="list-unstyled widget-group-list">
						<cfloop array="#groups#" item="group">
							<li class="widget-group <cfif selectedgroup == group>selected</cfif>">
								<a href="##fieldset-#group#" class="widget-group-link" data-widget-group="#group#">
									#translateResource( uri="admindashboards:group.#group#.label", defaultValue=UcFirst( group ) )#
								</a>
							</li>
						</cfloop>

						<li class="widget-group">
							<hr />
						</li>

						<li class="widget-group">
							<a href="##fieldset-uncategorised" class="widget-group-link" data-widget-group="uncategorised">
								#translateResource( uri="admindashboards:group.uncategorised.label" )#
							</a>
						</li>
					</ul>
				</div>
			</div>

			<div class="col-sm-9">
				<cfloop array="#groups#" item="group">
					<cfset widgets = arrayOfStructsToQuery( widgetQueryFields, grouped[ group ] ) />

					#renderView( view="admin/admindashboards/_browserDialogItems", args={ widgets=widgets, groupId=group } )#
				</cfloop>

				<cfif ArrayLen( grouped.uncategorised ?: [] )>
					#renderView( view="admin/admindashboards/_browserDialogItems", args={
						  widgets    = arrayOfStructsToQuery( widgetQueryFields, grouped.uncategorised )
						, groupId = "uncategorised"
					} )#
				</cfif>
			</div>
		</div>
	<cfelse>
		#renderView( view="admin/admindashboards/_browserDialogItems", args={ widgets=prc.widgets ?: QueryNew( "" ) } )#
	</cfif>
</cfoutput>