<cfscript>
	formId         = "batch-edit-form";
	formName       = prc.formName       ?: "";
	savedData      = prc.savedData      ?: {};
	additionalArgs = prc.additionalArgs ?: {};
	recordCount    = prc.recordCount    ?: 0;
	cancelLink     = event.buildAdminLink( objectName="admin_dashboard_snapshot_schema" );
	submitAction   = event.buildAdminLink( linkTo="datamanager.admin_dashboard_snapshot_schema.batchEditAction" );
</cfscript>

<cfoutput>
	<div class="alert alert-info">
		<i class="fa fa-fw fa-info-circle"></i>
		#translateResource( uri="preside-objects.admin_dashboard_snapshot_schema:batch.edit.info", data=[ numberFormat( recordCount ) ] )#
	</div>

	<form id="#formId#" action="#submitAction#" method="post" class="form form-horizontal">
		<input type="hidden" name="target" value="#HtmlEditFormat( rc.target ?: '' )#">

		#renderForm(
			  formName         = formName
			, context          = "admin"
			, formId           = formId
			, savedData        = savedData
			, additionalArgs   = additionalArgs
			, validationResult = rc.validationResult ?: ""
		)#

		<div class="form-actions row">
			<div class="col-md-offset-2">
				<a href="#cancelLink#" class="btn btn-default" data-global-key="c">
					<i class="fa fa-fw fa-reply bigger-110"></i>
					#translateResource( "cms:cancel.btn" )#
				</a>

				<button type="submit" class="btn btn-info" tabindex="#getNextTabIndex()#">
					<i class="fa fa-fw fa-check bigger-110"></i>
					#translateResource( "preside-objects.admin_dashboard_snapshot_schema:batch.edit.submit" )#
				</button>
			</div>
		</div>
	</form>
</cfoutput>
