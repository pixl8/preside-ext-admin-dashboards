/**
 * @presideService true
 * @singleton      true
 */
component extends="preside.system.services.concurrency.AbstractHeartBeat" {

	/**
	 * @adminDashboardSnapshotService.inject adminDashboardSnapshotService
	 * @scheduledThreadpoolExecutor.inject   presideScheduledThreadpoolExecutor
	 * @hostname.inject                      coldbox:setting:heartbeats.taskmanager.hostname
	 */
	public function init(
		  required any    adminDashboardSnapshotService
		, required any    scheduledThreadpoolExecutor
		, required string hostname
	) {
		super.init(
			  threadName                  = "Preside Heartbeat: Admin Dashboard Snapshot Processor"
			, intervalInMs                = ( 1000 * 60 * 60 ) // every 60 minutes
			, scheduledThreadpoolExecutor = arguments.scheduledThreadpoolExecutor
			, hostname                    = arguments.hostname
			, feature                     = "adminDashboardSnapshots"
		);

		_setAdminDashboardSnapshotService( arguments.adminDashboardSnapshotService );

		return this;
	}

	// PUBLIC API METHODS
	public void function $run() {
		try {
			_getAdminDashboardSnapshotService().processScheduledSnapshots();
		} catch( any e ) {
			$raiseError( e );
		}
	}


// GETTERS AND SETTERS
	private any function _getAdminDashboardSnapshotService() {
		return _adminDashboardSnapshotService;
	}
	private void function _setAdminDashboardSnapshotService( required any adminDashboardSnapshotService ) {
		_adminDashboardSnapshotService = arguments.adminDashboardSnapshotService;
	}

}
