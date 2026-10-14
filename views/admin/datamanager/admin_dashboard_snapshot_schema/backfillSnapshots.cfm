<cfscript>
	formId         = "backfill-snapshots-form";
	formName       = prc.formName       ?: "";
	savedData      = prc.savedData      ?: {};
	additionalArgs = prc.additionalArgs ?: {};
	registrationId = prc.registrationId ?: rc.id ?: "";
	cancelLink     = event.buildAdminLink( objectName="admin_dashboard_snapshot_schema", recordId=registrationId );
	submitAction   = event.buildAdminLink( linkTo="datamanager.admin_dashboard_snapshot_schema.backfillSnapshotsAction" );
</cfscript>

<cfoutput>
	<div class="alert alert-warning">
		<i class="fa fa-fw fa-exclamation-triangle"></i>
		<strong>#translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.warning" )#</strong>
	</div>

	<form id="#formId#" action="#submitAction#" method="post" class="form form-horizontal">
		<input type="hidden" name="id" value="#HtmlEditFormat( registrationId )#">

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

				<button type="submit" class="btn btn-primary" tabindex="#getNextTabIndex()#">
					<i class="fa fa-fw fa-history bigger-110"></i>
					#translateResource( "preside-objects.admin_dashboard_snapshot_schema:backfill.submit" )#
				</button>
			</div>
		</div>
	</form>
</cfoutput>
