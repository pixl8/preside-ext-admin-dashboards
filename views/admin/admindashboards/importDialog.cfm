<cfoutput>
	<form id="admin-dashboard-widget-import-form" action="" method="post" class="form-horizontal">
		<div class="form-group form-group-grid">
			<label class="control-label no-padding-right">
				#translateResource( uri="admindashboards:export.widget.label" )#

				<em class="required" role="presentation">
					<sup><i class="fa fa-asterisk"></i></sup>
					<span>#translateResource( "cms:form.control.required.label" )#</span>
				</em>
			</label>

			<div>
				<div class="clearfix">
					<textarea name="import" class="form-control autosize-transition" required></textarea>
				</div>
			</div>
		</div>
	</form>
</cfoutput>