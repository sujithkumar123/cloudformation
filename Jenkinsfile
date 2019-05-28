

 def env=Dev
// ...
stage('deploy') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'jenkins',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
            AWS_ACCESS_KEY_ID=AKIAWGL6VZOASNDSE6NA
            AWS_SECRET_ACCESS_KEY=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
        ]]) {
             if(env==Dev)
            sh 'AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} AWS_DEFAULT_REGION=us-east-1  aws cloudformation create-stack --stack-name myteststack --template-body file://vpc.yaml --parameters  PMServerEnv=Dev PMVpcCIDR=10.0.0.0/16 PMPublicSubnet1CIDR=10.0.0.0/24 PMPublicSubnet2CIDR=10.0.1.0/24 PMPublicSubnetCIDR=10.0.2.0/24 PMPrivateSubnet1CIDR=10.0.3.0/24 PMPrivateSubnet2CIDR=10.0.4.0/24 PMPrivateSubnet3CIDR=10.0.5.0/24 PMFlowLogRole=arn:aws:iam::426004302721:role/delivery
            else
            sh 'AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} AWS_DEFAULT_REGION=us-east-1 aws cloudformation create-stack --stack-name myteststack --template-body file://vpc.yaml --parameters  PMServerEnv=Dev PMVpcCIDR=10.0.0.0/16 PMPublicSubnet1CIDR=10.0.0.0/24 PMPublicSubnet2CIDR=10.0.1.0/24 PMPublicSubnetCIDR=10.0.2.0/24 PMPrivateSubnet1CIDR=10.0.3.0/24 PMPrivateSubnet2CIDR=10.0.4.0/24 PMPrivateSubnet3CIDR=10.0.5.0/24 PMFlowLogRole=arn:aws:iam::426004302721:role/delivery
}
    }
}
