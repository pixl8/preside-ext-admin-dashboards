<cfscript>
	savedData        = rc.formData          ?: prc.savedData;
	validationResult = prc.validationResult ?: "";
	dashboardId      = prc.recordId         ?: "";
	formId           = "dashboard-sharing-#dashboardId#";
	formName         = prc.formName         ?: "";
	formAction       = event.buildAdminLink( linkTo="datamanager.admin_dashboard.sharingAction", queryString="id=#dashboardId#" );
</cfscript>

<cfoutput>
	<form action="#formAction#" id="#formId#" method="post" data-auto-focus-form="true" data-dirty-form="protect" class="form-horizontal">
		#renderForm(
			  formName         = formName
			, formId           = formId
			, savedData        = savedData
			, validationResult = validationResult
			, context          = "admin"
		)#

		<div class="form-actions row">
			<div class="col-md-offset-2">
				<a href="#event.buildAdminLink( objectName="admin_dashboard", recordId=dashboardId )#" class="btn btn-default" data-global-key="c">
					<i class="fa fa-reply bigger-110"></i>
					#translateResource( "cms:cancel.btn" )#
				</a>

				<button class="btn btn-info" type="submit">
					<i class="fa fa-check bigger-110"></i>
					#translateResource( "cms:save.btn" )#
				</button>
			</div>
		</div>
	</form>
</cfoutput>