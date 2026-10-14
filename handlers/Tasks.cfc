component {

	property name="adminDashboardSnapshotService" inject="adminDashboardSnapshotService";

	/**
	 * Process all active admin dashboard snapshot registrations that are due for a snapshot
	 *
	 * @displayName  Process admin dashboard scheduled snapshots
	 * @displayGroup Admin Dashboards
	 * @schedule     0 0 6 * * *
	 * @feature      adminDashboardSnapshots
	 */
	private boolean function processScheduledSnapshots( event, rc, prc, logger ) {
		adminDashboardSnapshotService.processScheduledSnapshots( logger=arguments.logger ?: NullValue() );

		return true;
	}

}