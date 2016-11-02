# Ruby Jet

[![Build Status](https://travis-ci.org/jasonwells/ruby-jet.svg)](https://travis-ci.org/jasonwells/ruby-jet)
[![CircleCI](https://circleci.com/gh/jasonwells/ruby-jet.svg?style=shield)](https://circleci.com/gh/jasonwells/ruby-jet)
[![Dependency Status](https://gemnasium.com/jasonwells/ruby-jet.svg)](https://gemnasium.com/jasonwells/ruby-jet)
[![Code Climate](https://codeclimate.com/github/jasonwells/ruby-jet/badges/gpa.svg)](https://codeclimate.com/github/jasonwells/ruby-jet)
[![Test Coverage](https://codeclimate.com/github/jasonwells/ruby-jet/badges/coverage.svg)](https://codeclimate.com/github/jasonwells/ruby-jet/coverage)
[![Gem Version](https://badge.fury.io/rb/ruby-jet.svg)](https://badge.fury.io/rb/ruby-jet)

[Jet API](https://developer.jet.com/) service calls implemented in Ruby.

## Basic Usage

    require 'Jet'

    jet_client = Jet.client(merchant_id: "your_merch_id", api_user: "your_api_user", secret: "your_secret")

## Products
[Jet Products API](https://developer.jet.com/docs/merchant-sku)

    # Product Attributes
    attrs = {product_title: 'My Product',
              ASIN:           '12345ABCDE',
              brand:          "My Product's Brand",
              manufacturer:   "My Product's Manufacturer",
              main_image_url: 'https://c2.q-assets.com/images/products/p/asj/asj-077_1z.jpg',
              bullets:        [ "This is bullet line 1",
                                "This is bullet line 2",
                              ],
              product_description: "This is a terrific product that everyone should own.",
              multipack_quantity: 1,
            }

    # Call products.update_product to add a new product or update an existing one.
    # If the SKU is new, a new product will be created.

    response = jet_client.products.update_product('MyNewSku123', attrs)

    # Retrieve an existing product
    product = jet_client.products.get_product('MyNewSku123')

    # Set the price on a product
    response = jet_client.products.update_price('MyNewSku123', price: 30.95)

    # Update the inventory
    response = jet_client.products.update_inventory('MyNewSku123',
                                    fulfillment_nodes: [
                                                    {fulfillment_node_id: 'node1234', quantity: 100},
                                                    {fulfillment_node_id: 'node5678', quantity: 20}
                                                    ])

## Retrieve Orders
[Jet Orders API](https://developer.jet.com/docs/order-status)

get_orders defaults to 'ready' status
    response = jet_client.orders.get_orders
    ready_orders = response['order_urls']

Retrieve acknowledged orders
    response = jet_client.orders.get_orders(:acknowledged)
    acknowledged_orders = response['order_urls']

Other status options are:
    :created
    :ready
    :acknowledged
    :inprogress
    :complete

Retrieve a specific order
    order_url = ready_orders.first
    order = jet_client.orders.get_order(order_url)

## Acknowledge an Order
[Jet Acknowledge Order API](https://developer.jet.com/docs/acknowledge-order)

    jet_order_id = order['merchant_order_id']
    response = jet_client.orders.acknowledge_order(jet_order_id,
                          acknowledgement_status: 'accepted',
                          alt_order_id: '232145', #optional
                          order_items: [
                              { order_item_acknowledgement_status: 'fulfillable',
                                order_item_id: 'b81f073b18f548b892f6d4497af16297',
                                alt_order_item_id: '554443322' # optional
                              }
                            ]
                          )





