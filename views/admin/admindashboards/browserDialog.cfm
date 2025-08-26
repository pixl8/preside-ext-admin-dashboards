<cfscript>
	grouped           = prc.grouped    ?: {};
	groups            = prc.groups ?: StructKeyArray( grouped );
	selectedgroup     = Len( rc.group ?: "" ) ? rc.group : "";
	widgetQueryFields = "id,title,group,description,icon,previewImg,isTemplate,recordId,config";
</cfscript>

<cfoutput>
	<cfif ArrayLen( groups )>
		<div class="admin-dashboard-widgets-container">
			<div class="row">
				<div class="col-sm-12">
					<h2 class="dialog-title">#translateResource( uri="admindashboards:widget.dialog.title" )#</h2>

					<div class="dialog-search-input-group">
						<span class="dialog-search-input-addon">
							<i class="fa fa-fw #translateResource( uri="admindashboards:widget.dialog.search.icon" )#"></i>
						</span>
						<input class="dialog-search-input form-control"
						       type="input"
						       name="q"
						       autocomplete="off"
						       placeholder="#translateResource( uri="admindashboards:widget.dialog.search.placeholder" )#"
						/>
					</div>
				</div>
			</div>

			<div class="row">
				<div class="col-sm-12">
					<div class="widget-group-menu">
						<ul class="list-unstyled widget-group-list">
							<li class="widget-group <cfif isEmptyString( selectedgroup )>selected</cfif>">
								<a href="##fieldset-all" class="widget-group-link" data-widget-group="">
									#translateResource( uri="admindashboards:group.all.label" )#
								</a>
							</li>

							<cfloop array="#groups#" item="group">
								<li class="widget-group <cfif selectedgroup == group>selected</cfif>">
									<a href="##fieldset-#group#" class="widget-group-link" data-widget-group="#group#">
										#translateResource( uri="admindashboards:group.#group#.label", defaultValue=UcFirst( group ) )#
									</a>
								</li>
							</cfloop>

							<li class="widget-group <cfif selectedgroup == "uncategorised">selected</cfif>">
								<a href="##fieldset-uncategorised" class="widget-group-link" data-widget-group="uncategorised">
									#translateResource( uri="admindashboards:group.uncategorised.label" )#
								</a>
							</li>
						</ul>
					</div>
				</div>
			</div>

			<div class="row">
				<div class="col-sm-12">
					<ul class="list-unstyled admin-dashboard-widget-picker">
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
					</ul>
				</div>
			</div>
		</div>
	<cfelse>
		#renderView( view="admin/admindashboards/_browserDialogItems", args={ widgets=prc.widgets ?: QueryNew( "" ) } )#
	</cfif>
</cfoutput>