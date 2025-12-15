<cfscript>
	config = prc.config ?: {};
</cfscript>

<cfoutput>
	<div class="alert alert-info">
		#translateResource( uri="admindashboards:export.widget.dialog.description" )#
	</div>

	<div class="form-group form-group-grid">
		<label class="control-label no-padding-right">
			#translateResource( uri="admindashboards:export.widget.label" )#
		</label>

		<div>
			<div class="clearfix">
				<textarea name="export" class="form-control autosize-transition">#Trim( SerializeJSON( config ) )#</textarea>
			</div>
		</div>
	</div>
</cfoutput>