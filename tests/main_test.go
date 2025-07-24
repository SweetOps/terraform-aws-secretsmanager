package test

import (
	"context"
	"fmt"
	"strings"
	"testing"

	terra_rand "github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	terra_ts "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/modules/localstack"
)

const (
	RootFolder         string = ".."
	AWSDefaultRegion   string = "us-east-1"
	AWSAccessKeyID     string = "anaccesskey"
	AWSSecretAccessKey string = "asecretkey"
)

var (
	LocalStackImage    string = "localstack/localstack:3"
	LocalStackServices string = "kms,secretsmanager"
)

func initWorkingDir(t *testing.T, rootFolder, terraformFolderRelativeToRoot string) string {
	return terra_ts.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)
}

func runLocalStack(ctx context.Context, image, services string) (*localstack.LocalStackContainer, error) {
	return localstack.Run(
		ctx,
		image,
		testcontainers.WithEnv(map[string]string{
			"SERVICES": services,
		}),
	)
}

func getLocalStackEndpoint(ctx context.Context, localstackContainer *localstack.LocalStackContainer) (string, error) {
	host, err := localstackContainer.Host(ctx)
	if err != nil {
		return "", err
	}

	port, err := localstackContainer.MappedPort(ctx, "4566")
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("http://%s:%s", host, port.Port()), nil
}

func deploy(t *testing.T, workingDir, awsEndpoint string) {
	attribute := strings.ToLower(terra_rand.UniqueId())
	terra_ts.SaveString(t, workingDir, "attribute", attribute)

	tfOpts := terraform.WithDefaultRetryableErrors(
		t,
		&terraform.Options{
			TerraformDir: workingDir,
			Vars: map[string]interface{}{
				"attributes":          []string{attribute},
				"localstack_endpoint": awsEndpoint,
			},
			EnvVars: map[string]string{
				"AWS_ACCESS_KEY_ID":     AWSAccessKeyID,
				"AWS_SECRET_ACCESS_KEY": AWSSecretAccessKey,
				"AWS_DEFAULT_REGION":    AWSDefaultRegion,
			},
		},
	)

	terra_ts.SaveTerraformOptions(t, workingDir, tfOpts)
	terraform.InitAndApply(t, tfOpts)
}

func validateOutputs(t *testing.T, workingDir string) {
	tfOpts := terra_ts.LoadTerraformOptions(t, workingDir)
	attribute := terra_ts.LoadString(t, workingDir, "attribute")

	id := terraform.Output(t, tfOpts, "id")
	name := terraform.Output(t, tfOpts, "name")
	arn := terraform.Output(t, tfOpts, "arn")
	version_id := terraform.Output(t, tfOpts, "version_id")
	kms_key_alias_arn := terraform.Output(t, tfOpts, "kms_key_alias_arn")
	kms_key_alias_name := terraform.Output(t, tfOpts, "kms_key_alias_name")
	kms_key_arn := terraform.Output(t, tfOpts, "kms_key_arn")
	kms_key_id := terraform.Output(t, tfOpts, "kms_key_id")

	assert.Equal(t, fmt.Sprintf("alias/so-staging-alpha-%s", attribute), kms_key_alias_name)
	assert.Equal(t, fmt.Sprintf("arn:aws:kms:%s:000000000000:alias/so-staging-alpha-%s", AWSDefaultRegion, attribute), kms_key_alias_arn)
	assert.Contains(t, kms_key_arn, fmt.Sprintf("arn:aws:kms:%s:000000000000:key/", AWSDefaultRegion))
	assert.Equal(t, fmt.Sprintf("so-staging-alpha-%s", attribute), name)
	assert.NotEmpty(t, version_id)
	assert.NotEmpty(t, kms_key_id)
	assert.Contains(t, id, fmt.Sprintf("arn:aws:secretsmanager:%s:000000000000:secret:so-staging-alpha-%s-", AWSDefaultRegion, attribute))
	assert.Contains(t, arn, fmt.Sprintf("arn:aws:secretsmanager:%s:000000000000:secret:so-staging-alpha-%s-", AWSDefaultRegion, attribute))
}
