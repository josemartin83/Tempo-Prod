global class AWSCalloutSchedular implements Schedulable {
    
	global void execute(SchedulableContext ctx) {
        //execute AWSCalloutBatch class
        AWSCalloutBatch awsCalloutBatch = new AWSCalloutBatch();
        Database.executeBatch(awsCalloutBatch);
        
    }
    
}