<cfscript>
	availableTypes = args.availableTypes ?: [];
	selectedType   = args.selectedType   ?: "";

	errorMessages    = {};
	validationResult = rc.validationResult ?: "";
	if ( !IsSimpleValue( validationResult ) ) {
		errorMessages = validationResult.getMessages();
	}
</cfscript>

<cfoutput>
	<cfif ArrayLen( availableTypes )>
		<cfset hasError = StructKeyExists( errorMessages, "widget_type" ) />

		<div class="admin-dashboards-widget-type-list #hasError ? "has-error" : ""#">
			<cfloop array="#availableTypes#" item="type">
				<cfset typeId = type.id />

				<div class="widget-type-item">
					<input class="widget-type-input"
					       type="radio"
					       name="widget_type"
					       id="#typeId#"
					       value="#typeId#"
					       <cfif selectedType == typeId>checked</cfif>
					/>

					<label class="widget-type-wrapper" for="#typeId#">
						<div class="widget-type-icon">
							<i class="fa fa-fw #translateResource( uri="enum.adminDashboardWidgetType:#typeId#.iconclass" )#"></i>
						</div>

						<div class="widget-type-info">
							<p class="widget-type-label">#type.label#</p>
							<cfif Len( type.description ?: "" )>
								<p class="widget-type-desc">#type.description#</p>
							</cfif>
						</div>

						<div class="widget-type-cta">
							<cfif typeId != "import">
								<i class="fa fa-fw fa-angle-right"></i>
							</cfif>
						</div>
					</label>
				</div>

				<cfif typeId == "import">
					<cfset importHasError = StructKeyExists( errorMessages, "import_code" ) />

					<div class="widget-type-item widget-type-import-item hide #importHasError ? "has-error" : ""#">
						<div class="widget-type-wrapper">
							<div class="alert alert-info">
								<i class="fa fa-fw fa-info"></i>
								#translateResource( uri="webflow.adminDashboardsAddWidget:step.selectType.import.alert.msg" )#
							</div>

							<label for="import_code" class="control-label">
								#translateResource( uri="webflow.adminDashboardsAddWidget:step.selectType.field.import_code.label" )#
							</label>

							<textarea id="import_code"
							          name="import_code"
							          class="form-control"
							>#Trim( args.importCode ?: "" )#</textarea>

							<cfif importHasError && Len( errorMessages.import_code.message ?: "" )>
								<div for="import_code" class="help-block">
									#errorMessages.import_code.message#
								</div>
							</cfif>
						</div>
					</div>
				</cfif>
			</cfloop>

			<cfif hasError && Len( errorMessages.widget_type.message ?: "" )>
				<div class="help-block">
					#errorMessages.widget_type.message#
				</div>
			</cfif>
		</div>
	</cfif>
</cfoutput>