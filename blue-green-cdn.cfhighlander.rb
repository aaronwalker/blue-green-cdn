CfhighlanderTemplate do

  
    Parameters do
      ComponentParam 'EnvironmentName', 'devfe'
      ComponentParam 'BlueBucketName', 'devfe'
      ComponentParam 'GreenBucketName', 'devfe'
    end

    Component name: 'cdn', template: 'cloudfront@0.7.1', render: Inline, config: cdn do
      buckets.each do |id, bucket|
        parameter name: "#{id}OriginDomainName", value: FnGetAtt("#{id}Bucket", "DomainName")
      end
    end
    
  end