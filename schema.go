// Copyright 2019
// The Honest Scoop and P.J. Siripala
// All rights reserved

package main

import (
	"context"
	"log"

	"github.com/dgraph-io/dgo/protos/api"
)

func setSchema() {

	op := &api.Operation{}
	op.Schema = `
		user: bool .
		user.name: string @index(hash) .
		user.email: string @index(hash) .
		user.password: password .
		user.code: string . 
		user.created_at: dateTime .
		user.validated: bool @index(bool) .

		node: bool .
		node.hashid: string @index(hash) . 
		node.owner: uid @reverse . 
		node.parent: uid . 
		node.xdata: string . 
		node.searchable: bool @index(bool) . 
		node.search_title: string @index(term) .
		node.search_synopsis: string @index(fulltext) .
		node.created_at: dateTime .
	`

	// err := dg.Alter(context.Background(), &api.Operation{DropAll: true})
	err := dg.Alter(context.Background(), op)
	if err != nil {
		log.Fatal(err)
	}

}

// user: bool .
// user.name: string @index(hash) . # this should be unique
// user.email: string @index(hash) . # this should be unique and lower-cased
// user.password: password .
// user.code: string . # for password recovery (can be null)
// user.created_at: dateTime .
// user.validated: bool @index(bool) . # Check if email validation passed

// node: bool .
// node.hashid: string @index(exact) . # @username/hashid
// node.owner: uid @reverse . # (can be null)
// node.parent: uid . # [uid] (use facet) (can be null)
// node.xdata: string . # store custom json data
// node.searchable: bool @index(bool) .
// node.search_title: string @index(term) . # (can be null)
// node.search_synopsis: string @index(fulltext) . # (can be null)
// node.created_at: dateTime .
