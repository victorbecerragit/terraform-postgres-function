// Package p contains a Pub/Sub Cloud Function.
package p

import (
	"context"
	"encoding/json"
	"log"
	"os"

	"golang.org/x/oauth2/google"
	sqladmin "google.golang.org/api/sqladmin/v1beta4"
)

// PubSubMessage is the payload of a Pub/Sub event.
// See the documentation for more details:
// https://cloud.google.com/pubsub/docs/reference/rest/v1/PubsubMessage
type PubSubMessage struct {
	Data []byte `json:"data"`
}

//Changed the default payload to one record to make more easy push messages with the scheduler
type MessagePayload struct {
	//Instance string
	//Project  string
	Action   string
}

// GOOGLE_CLOUD_PROJECT is a user-set environment variable.
// Define project and SQL instance as environment variable, to make the function more Independent.
var projectID = os.Getenv("CLOUD_PROJECT_ID")
var instanceName = os.Getenv("PSQL_INSTANCE_NAME")

// ProcessPubSub consumes and processes a Pub/Sub message.
func ProcessPubSub(ctx context.Context, m PubSubMessage) error {
	var psData MessagePayload
	err := json.Unmarshal(m.Data, &psData)
	if err != nil {
		log.Println(err)
	}
	log.Printf("Request received for Cloud SQL instance %s action: %s, %s", psData.Action, instanceName, projectID)

	// Create an http.Client that uses Application Default Credentials.
	hc, err := google.DefaultClient(ctx, sqladmin.CloudPlatformScope)
	if err != nil {
		return err
	}

	// Create the Google Cloud SQL service.
	service, err := sqladmin.New(hc)
	if err != nil {
		return err
	}

	// Get the requested start or stop Action.
	action := "UNDEFINED"
	switch psData.Action {
	case "start":
		action = "ALWAYS"
	case "stop":
		action = "NEVER"
	default:
		log.Fatal("No valid action provided.")
	}

	// See more examples at:
	// https://cloud.google.com/sql/docs/sqlserver/admin-api/rest/v1beta4/instances/patch
	// for postgres https://cloud.google.com/sql/docs/postgres/admin-api/rest/v1beta4/instances/patch
	rb := &sqladmin.DatabaseInstance{
		Settings: &sqladmin.Settings{
			ActivationPolicy: action,
		},
	}

	resp, err := service.Instances.Patch(projectID, instanceName, rb).Context(ctx).Do()
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("%#v\n", resp)
	return nil
}
