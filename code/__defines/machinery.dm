var/global/defer_powernet_rebuild = 0      // True if net rebuild will be called manually after an event.

#define KILOWATTS *1000
#define MEGAWATTS *1000000
#define GIGAWATTS *1000000000

#define MACHINERY_TICKRATE 2		// Tick rate for machinery in seconds. As it affects CELLRATE calculation it is kept as define here

#define CELLRATE (1 / ( 3600 / MACHINERY_TICKRATE )) // Multiplier for charge units. Converts cell charge units(watthours) to joules. Takes into consideration that our machinery ticks once per two seconds.

// Doors!
#define DOOR_CRUSH_DAMAGE 40

#define POWER_USE_OFF    0
#define POWER_USE_IDLE   1
#define POWER_USE_ACTIVE 2

// Channel numbers for power.
#define POWER_CHAN -1 // Use default channel
#define EQUIP   1
#define LIGHT   2
#define ENVIRON 3
#define LOCAL   4 // Machines running on local power. Not tracked by area.
#define TOTAL   5 // For total power used only.

// Bitflags for machine stat variable.
#define BROKEN   BITFLAG(0)
#define NOPOWER  BITFLAG(1)
#define MAINT    BITFLAG(2) // Under maintenance.
#define EMPED    BITFLAG(3) // Temporary broken by EMP.
#define NOSCREEN BITFLAG(4) // No UI shown via direct interaction
#define NOINPUT  BITFLAG(5) // No input taken from direct interaction

#define MACHINE_BROKEN_GENERIC   BITFLAG(0) // Standard legacy brokenness, used on a case-by-case basis
#define MACHINE_BROKEN_NO_PARTS  BITFLAG(1) // Missing required parts
#define MACHINE_BROKEN_CONSTRUCT BITFLAG(2) // Construction state is causing the brokenness

// Used by firelocks
#define FIREDOOR_OPEN 1
#define FIREDOOR_CLOSED 2

#define AI_CAMERA_LUMINOSITY 6

// Camera channels
// Station channels
#define CAMERA_CHANNEL_PUBLIC              "Public"
#define CAMERA_CHANNEL_ENGINEERING         "Engineering"
#define CAMERA_CHANNEL_MEDICAL             "Medical"
#define CAMERA_CHANNEL_RESEARCH            "Research"
#define CAMERA_CHANNEL_SECURITY            "Security"
#define CAMERA_CHANNEL_ROBOTS              "Robots"
#define CAMERA_CHANNEL_MINE                "Mining"
#define CAMERA_CHANNEL_SECRET              "Secret"
#define CAMERA_CHANNEL_COMMAND             "Command"
#define CAMERA_CHANNEL_ENGINE              "Engine"
#define CAMERA_CHANNEL_ENGINEERING_OUTPOST "Engineering Outpost"
#define CAMERA_CHANNEL_BASEMENT_FLOOR      "Basement Floor"
#define CAMERA_CHANNEL_GROUND_FLOOR        "Ground Floor"
#define CAMERA_CHANNEL_SECOND_FLOOR        "Second Floor"
#define CAMERA_CHANNEL_SUPPLY              "Supply"
#define CAMERA_CHANNEL_ENTERTAINMENT       "Entertainment"
#define CAMERA_CHANNEL_TOXINS              "Toxins Test Area"
#define CAMERA_CHANNEL_MISC_RESEARCH       "Miscellaneous Research"

// Non-station channels
#define CAMERA_CHANNEL_CRESCENT            "Crescent"
#define CAMERA_CHANNEL_ERT                 "Emergency Response Team"
#define CAMERA_CHANNEL_MERCENARY           "MercurialNet"
#define CAMERA_CHANNEL_TELEVISION          "Television"

// Alarm networks
#define NETWORK_ALARM_ATMOS  "Atmosphere Alarms"
#define NETWORK_ALARM_CAMERA "Camera Alarms"
#define NETWORK_ALARM_FIRE   "Fire Alarms"
#define NETWORK_ALARM_MOTION "Motion Alarms"
#define NETWORK_ALARM_POWER  "Power Alarms"

//singularity defines
#define STAGE_ONE 	1
#define STAGE_TWO 	3
#define STAGE_THREE	5
#define STAGE_FOUR	7
#define STAGE_FIVE	9

// NanoUI flags
#define STATUS_INTERACTIVE 2 // GREEN Visability
#define STATUS_UPDATE 1 // ORANGE Visability
#define STATUS_DISABLED 0 // RED Visability
#define STATUS_CLOSE -1 // Close the interface

/*
 *	Atmospherics Machinery.
*/
#define MAX_SIPHON_FLOWRATE   2500 // L/s. This can be used to balance how fast a room is siphoned. Anything higher than CELL_VOLUME has no effect.
#define MAX_SCRUBBER_FLOWRATE 200  // L/s. Max flow rate when scrubbing from a turf.

// These balance how easy or hard it is to create huge pressure gradients with pumps and filters.
// Lower values means it takes longer to create large pressures differences.
// Has no effect on pumping gasses from high pressure to low, only from low to high.
#define ATMOS_PUMP_EFFICIENCY   2.5
#define ATMOS_FILTER_EFFICIENCY 2.5

// Will not bother pumping or filtering if the gas source as fewer than this amount of moles, to help with performance.
#define MINIMUM_MOLES_TO_PUMP   0.01
#define MINIMUM_MOLES_TO_FILTER 0.04

// The flow rate/effectiveness of various atmos devices is limited by their internal volume,
// so for many atmos devices these will control maximum flow rates in L/s.
#define ATMOS_DEFAULT_VOLUME_PUMP   200 // Liters.
#define ATMOS_DEFAULT_VOLUME_FILTER 500 // L.
#define ATMOS_DEFAULT_VOLUME_MIXER  500 // L.
#define ATMOS_DEFAULT_VOLUME_PIPE   70  // L.

// Scrubber modes
#define SCRUBBER_SIPHON   "siphon"
#define SCRUBBER_SCRUB    "scrub"
#define SCRUBBER_EXCHANGE "exchange"

//Docking program
#define STATE_UNDOCKED		0
#define STATE_DOCKING		1
#define STATE_UNDOCKING		2
#define STATE_DOCKED		3

#define MODE_NONE			0
#define MODE_SERVER			1
#define MODE_CLIENT			2	//The one who initiated the docking, and who can initiate the undocking. The server cannot initiate undocking, and is the one responsible for deciding to accept a docking request and signals when docking and undocking is complete. (Think server == station, client == shuttle)

#define MESSAGE_RESEND_TIME 5	//how long (in seconds) do we wait before resending a message

// obj/item/stock_parts status flags
#define PART_STAT_INSTALLED  1
#define PART_STAT_PROCESSING 2
#define PART_STAT_ACTIVE     4
#define PART_STAT_CONNECTED  8

// part_flags
#define PART_FLAG_LAZY_INIT   1 // Will defer init on stock parts until machine is destroyed or parts are otherwise queried.
#define PART_FLAG_QDEL        2 // Will delete on uninstall
#define PART_FLAG_HAND_REMOVE 4 // Can be removed by hand

// Machinery process flags, for use with START_PROCESSING_MACHINE
#define MACHINERY_PROCESS_SELF       1
#define MACHINERY_PROCESS_COMPONENTS 2
#define MACHINERY_PROCESS_ALL        (MACHINERY_PROCESS_SELF | MACHINERY_PROCESS_COMPONENTS)

// Machine construction state return values, for use with cannot_transition_to
#define MCS_CHANGE   0 // Success
#define MCS_CONTINUE 1 // Failed to change, silently
#define MCS_BLOCK    2 // Failed to change, but action was performed

#define FABRICATOR_EXTRA_COST_FACTOR 1.25
#define FAB_HACKED   BITFLAG(0)
#define FAB_DISABLED BITFLAG(1)
#define FAB_SHOCKED  BITFLAG(2)
#define FAB_BUSY     BITFLAG(3)

#define  PART_CPU  		/obj/item/stock_parts/computer/processor_unit				// CPU. Without it the computer won't run. Better CPUs can run more programs at once.
#define  PART_NETWORK  	/obj/item/stock_parts/computer/network_card					// Network Card component of this computer. Allows connection to network
#define  PART_HDD 		/obj/item/stock_parts/computer/hard_drive					// Hard Drive component of this computer. Stores programs and files.

// Optional hardware (improves functionality, but is not critical for computer to work in most cases)
#define  PART_BATTERY  	/obj/item/stock_parts/computer/battery_module			// An internal power source for this computer. Can be recharged.
#define  PART_CARD  	/obj/item/stock_parts/computer/card_slot					// ID Card slot component of this computer. Mostly for HoP modification console that needs ID slot for modification.
#define  PART_PRINTER  	/obj/item/stock_parts/computer/nano_printer			// Nano Printer component of this computer, for your everyday paperwork needs.
#define  PART_DRIVE  	/obj/item/stock_parts/computer/hard_drive/portable		// Portable data storage
#define  PART_AI  		/obj/item/stock_parts/computer/ai_slot							// AI slot, an intelliCard housing that allows modifications of AIs.
#define  PART_TESLA  	/obj/item/stock_parts/computer/tesla_link					// Tesla Link, Allows remote charging from nearest APC.
#define  PART_SCANNER  	/obj/item/stock_parts/computer/scanner							// One of several optional scanner attachments.
#define  PART_D_SLOT	/obj/item/stock_parts/computer/drive_slot				// Portable drive slot.
#define  PART_MSTICK	/obj/item/stock_parts/computer/charge_stick_slot		// Charge-slot component for transactions /w charge sticks.
#define  PART_DSKSLOT	/obj/item/stock_parts/computer/data_disk_drive			// Temporary modcomp version of the disk reader component.