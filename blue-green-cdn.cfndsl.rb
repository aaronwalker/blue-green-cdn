CloudFormation do
  buckets = external_parameters.fetch(:buckets, {})
  buckets.each do |id,config|

    policy_document = {
      Version: '2008-10-17',
      Id: 'PolicyForCloudFrontContent',
      Statement: []
    }

    bucket_policy = config.has_key?('bucket_policy') ? config['bucket_policy'] : {}

    bucket_policy.each do |sid, statement_config|
      statement = {}
      statement["Sid"] = sid
      statement['Effect'] = statement_config.has_key?('effect') ? statement_config['effect'] : "Allow"
      statement['Principal'] = statement_config.has_key?('principal') ? statement_config['principal'] : {AWS: FnSub("arn:aws:iam::${AWS::AccountId}:root")}
      statement['Resource'] = statement_config.has_key?('resource') ? statement_config['resource'] : [FnJoin("",["arn:aws:s3:::", Ref("#{id}Bucket")]), FnJoin("",["arn:aws:s3:::", Ref("#{id}Bucket"), "/*"])]
      statement['Action'] = statement_config.has_key?('actions') ? statement_config['actions'] : ["s3:*"]
      statement['Condition'] = statement_config['conditions'] if statement_config.has_key?('conditions')
      policy_document[:Statement] << statement
    end


    bucket_encryption = config.has_key?('bucket_encryption') ? config['bucket_encryption'] : nil
    enable_s3_logging = config.has_key?('enable_s3_logging') ? config['enable_s3_logging'] : nil
    block_pub_access = config.has_key?('block_pub_access') ? config['block_pub_access'] : nil
    bucket_website = config.has_key?('bucket_website') ? config['bucket_website'] : nil

    Condition(:SetLogFilePrefix, FnNot(FnEquals(Ref(:LogFilePrefix), ''))) if enable_s3_logging

    S3_Bucket("#{id}Bucket") do
      BucketName FnSub(config['bucket_name'])
      PublicAccessBlockConfiguration block_pub_access unless block_pub_access.nil?
      LoggingConfiguration ({
        DestinationBucketName: Ref(:AccessLogsBucket),
        LogFilePrefix: FnIf(:SetLogFilePrefix, Ref(:LogFilePrefix), Ref('AWS::NoValue'))
      }) if enable_s3_logging
      BucketEncryption bucket_encryption unless bucket_encryption.nil?
      WebsiteConfiguration bucket_website unless bucket_website.nil?
    end

    S3_BucketPolicy("#{id}BucketPolicy") do
      Bucket Ref("#{id}Bucket")
      PolicyDocument policy_document
    end
  end
end