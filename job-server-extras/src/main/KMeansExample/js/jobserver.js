var dataURL = "http://ec2-54-237-78-154.compute-1.amazonaws.com:8090/jobs/e853d3ad-47cf-4252-8e97-9bb0b6c7c47c";
var jobURL;
var cluster_labels;
var cluster_points;

function reloadPageGraphics() {
	d3.json(dataURL, function(labelsAndData) {
		cluster_labels = labelsAndData.result[0];
		cluster_points = labelsAndData.result[1].map(JSON.parse);
		//build option list that will be converted to dropdwon
		for (var i = 0; i < cluster_labels.length; i++) {
			$('<option>', {
				value: cluster_labels[i]
			}).text(cluster_labels[i]).appendTo("#multiSelect")
		}
		//enable multiSelect dropdown
		$('#multiSelect').multiselect({
			enableFiltering: true,
			includeSelectAllOption: true,
			selectedClass: 'multiselect-selected',
		});
		//on click, update url
		$('input[type="checkbox"]').click(function() {
			window.history.pushState({}, "",URI(window.location.href).setQuery({active: getActiveLabels()}).toString())
		});
		//select those which are in URL
		$('#multiSelect').multiselect('select', URI(window.location.href).query(true)['active']);
		drawData();
	});
}

function getActiveLabels() {
	return $.makeArray($('label > :checked').map(function() {
		return this.value
	})).filter(function(val) {
		return val !== 'multiselect-all'
	});
}

function startContext() 
{	$("#state")[0].innerText = "Waiting for context to start.";
	disableAll();
	d3.json(jobserverURL + "/contexts/kmsc?spark.executor.instances=155", function(error, success) {
			haveContext = true
			$("#state")[0].innerText = "Ready to resample.";
			showContextRunning();
		})
		.send("POST", "");
}

function stopContext() {
	$("#state")[0].innerText = "Waiting for context to finish.";
	disableAll();
	d3.json(jobserverURL + "/contexts/kmsc", function(error, success) {
			$("#state")[0].innerText = "Please start a context.";
			showContextStopped();
		})
		.send("DELETE");
}

function runSampling() {
	$("#state")[0].innerText = "Resampling, please wait.";
	disableAll();
	d3.json(dataURL + "/jobs?appName=km&classPath=spark.jobserver.KMeansExample&context=kmsc", function(error, success) {
			var jobId = success.result.jobId;

			function getResult() {
				setTimeout(function() {
					d3.json(dataURL + "/jobs/" + jobId, function(error, success) {
						if (success.status === "RUNNING") {
							getResult();
						} else {
							reloadData();
						}
					})
				}, 1000)
			}
			getResult()
		})
		.send("POST", "");
}

function showContextRunning() {
	$(".enableWhileRunning").prop("disabled", false);
	$(".enableWhileStopped").prop("disabled", true);

}

function showContextStopped() {
	$(".enableWhileRunning").prop("disabled", true);
	$(".enableWhileStopped").prop("disabled", false);

}

function disableAll() {
	$(".enableWhileRunning").prop("disabled", true);
	$(".enableWhileStopped").prop("disabled", true);
}

function isContextRunning() {
	$("#state")[0].innerText = "Syncing with server.";
	d3.json(dataURL + "/contexts", function(error, success) {
		if ($.inArray("kmsc", success) !== -1) {
			haveContext = true;
			showContextRunning();
			$("#state")[0].innerText = "Ready to resample.";
		} else {
			haveContext = false;
			showContextStopped();
			$("#state")[0].innerText = "Please start a context.";
		}
	})
}

var haveContext = false;
function startPage() {
	isContextRunning();
	reloadPageGraphics();
}