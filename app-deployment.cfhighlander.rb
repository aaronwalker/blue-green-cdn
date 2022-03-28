CfhighlanderTemplate do

    Parameters do
      ComponentParam 'DeploymentSourceBucket'
      ComponentParam 'BlueDeploymentBucket'
      ComponentParam 'BlueVersion'
      ComponentParam 'GreenDeploymentBucket'
      ComponentParam 'GreenVersion'
    end
  
    Component name: 'bluedeploy', template: 's3-deployer@0.1.4', render: Inline do
      parameter name: 'DeploymentSourceBucket', value: Ref(:DeploymentSourceBucket)
      parameter name: 'DeploymentSourceKey', value: FnSub("artifacts/#{component_name}/${BlueVersion}/#{component_name}-${BlueVersion}.zip")
      parameter name: 'DeploymentBucket', value: Ref(:BlueDeploymentBucket)
      parameter name: 'DeploymentKey', value: ''
    end

    Component name: 'greendeploy', template: 's3-deployer@0.1.4', render: Inline do
        parameter name: 'DeploymentSourceBucket', value: Ref(:DeploymentSourceBucket)
        parameter name: 'DeploymentSourceKey', value: FnSub("artifacts/#{component_name}/${GreenVersion}/#{component_name}-${GreenVersion}.zip")
        parameter name: 'DeploymentBucket', value: Ref(:GreenDeploymentBucket)
        parameter name: 'DeploymentKey', value: ''
      end
  
  end