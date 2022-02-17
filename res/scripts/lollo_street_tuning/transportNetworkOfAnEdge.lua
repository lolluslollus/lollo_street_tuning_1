-- local tn = api.engine.getComponent(oldEdgeId, api.type.ComponentType.TRANSPORT_NETWORK)

local tn = {
    nodes = {
    },
    edges = {
      [1] = {
        conns = {
          [1] = {
            new = nil,
            entity = 74996, -- baseEdge.node1
            index = 1,
          },
          [2] = {
            new = nil,
            entity = 74995, -- baseEdge.node0
            index = 1,
          },
        },
        geometry = {
          params = {
            pos = { -- the pos of the node 74996 -- baseEdge.node1
              x = -5069.9208984375, -- position.x of node 74996 -- baseEdge.node1
              y = 2129.7473144531, -- position.y of node 74996 -- baseEdge.node1
            },
            tangent = {
              x = 30.316680908203, -- MINUS tangent1.x of edge
              y = -73.190567016602, -- MINUS tangent1.y of edge
            },
            offset = -7, -- comes from street type, it's always negative in two-way roads!
          },
          tangent = {
            x = 1.6819347143173, -- MINUS tangent1.z of edge
            y = -0.42324957251549, -- MINUS tangent0.z of edge
          },
          height = {
            x = 103.68836975098, -- same as in 6
            y = 105.02540588379, -- same as in 6
          },
          length = 81.732971191406, -- calculated, every lane is different
          width = 2, -- comes from street type
        },
        transportModes = {
          [1] = 1,
          [2] = 1,
          [3] = 0,
          [4] = 0,
          [5] = 0,
          [6] = 0,
          [7] = 0,
          [8] = 0,
          [9] = 0,
          [10] = 0,
          [11] = 0,
          [12] = 0,
          [13] = 0,
          [14] = 0,
          [15] = 0,
          [16] = 0,
        },
        speedLimit = 0,
        curveSpeedLimit = 0,
        curSpeed = 0,
        precedence = false,
      },
      [2] = {
        conns = {
          [1] = {
            new = nil,
            entity = 74996, -- baseEdge.node1
            index = 2,
          },
          [2] = {
            new = nil,
            entity = 74995, -- baseEdge.node0
            index = 2,
          },
        },
        geometry = {
          params = {
            pos = {
              x = -5069.9208984375, -- position.x of node 74996 -- baseEdge.node1
              y = 2129.7473144531, -- position.y of node 74996 -- baseEdge.node1
            },
            tangent = {
              x = 30.316680908203, -- MINUS tangent1.x of edge
              y = -73.190567016602, -- MINUS tangent1.y of edge
            },
            offset = -4.5, -- comes from street type, it's always negative in two-way roads!
          },
          tangent = {
            x = 1.6819347143173, -- MINUS tangent1.z of edge
            y = -0.42324957251549, -- MINUS tangent0.z of edge
          },
          height = {
            x = 103.38836669922, -- position.z of node 74996 -- baseEdge.node1
            y = 104.72540283203, -- position.z of node 74995 -- baseEdge.node0
          },
          length = 80.751037597656, -- calculated, every lane is different
          width = 3, -- comes from street type
        },
        transportModes = {
          [1] = 0,
          [2] = 0,
          [3] = 0,
          [4] = 1,
          [5] = 1,
          [6] = 1,
          [7] = 1,
          [8] = 0,
          [9] = 0,
          [10] = 0,
          [11] = 0,
          [12] = 0,
          [13] = 0,
          [14] = 0,
          [15] = 0,
          [16] = 0,
        },
        speedLimit = 13.888889312744,
        curveSpeedLimit = 22.996072769165,
        curSpeed = 9.167142868042,
        precedence = false,
      },
      [3] = {
        conns = {
          [1] = {
            new = nil,
            entity = 74996, -- baseEdge.node1
            index = 3,
          },
          [2] = {
            new = nil,
            entity = 74995, -- baseEdge.node0
            index = 3,
          },
        },
        geometry = {
          params = {
            pos = {
              x = -5069.9208984375, -- position.x of node 74996 -- baseEdge.node1
              y = 2129.7473144531, -- position.y of node 74996 -- baseEdge.node1
            },
            tangent = {
              x = 30.316680908203, -- MINUS tangent1.x of edge
              y = -73.190567016602, -- MINUS tangent1.y of edge
            },
            offset = -1.5, -- comes from street type, it's always negative in two-way roads!
          },
          tangent = {
            x = 1.6819347143173, -- MINUS tangent1.z of edge
            y = -0.42324957251549, -- MINUS tangent0.z of edge
          },
          height = {
            x = 103.38836669922, -- position.z of node 74996 -- baseEdge.node1
            y = 104.72540283203, -- position.z of node 74995 -- baseEdge.node0
          },
          length = 79.572715759277, -- calculated, every lane is different
          width = 3, -- comes from street type
        },
        transportModes = {
          [1] = 0,
          [2] = 0,
          [3] = 1,
          [4] = 1,
          [5] = 1,
          [6] = 0,
          [7] = 0,
          [8] = 0,
          [9] = 0,
          [10] = 0,
          [11] = 0,
          [12] = 0,
          [13] = 0,
          [14] = 0,
          [15] = 0,
          [16] = 0,
        },
        speedLimit = 13.888889312744,
        curveSpeedLimit = 22.828481674194,
        curSpeed = 9.167142868042,
        precedence = false,
      },
      [4] = {
        conns = {
          [1] = {
            new = nil,
            entity = 74995, -- baseEdge.node0
            index = 4,
          },
          [2] = {
            new = nil,
            entity = 74996, -- baseEdge.node1
            index = 4,
          },
        },
        geometry = {
          params = {
            pos = { -- the pos of node 74995 (baseEdge.node0)
              x = -5026.3291015625, -- position.x of node 74995 -- baseEdge.node0
              y = 2064.5080566406, -- position.y of node 74995 -- baseEdge.node0
            },
            tangent = {
              x = -56.029689788818, -- tangent0.x of edge
              y = 56.029323577881, -- tangent0.y of edge
            },
            offset = -1.5, -- comes from street type, it's always negative in two-way roads!
          },
          tangent = {
            x = 0.42324957251549, -- tangent0.z of edge
            y = -1.6819347143173, -- tangent1.z of edge
          },
          height = {
            x = 104.72540283203, -- position.z of node 74995 -- baseEdge.node0
            y = 103.38836669922, -- position.z of node 74996 -- baseEdge.node1
          },
          length = 78.394409179688, -- calculated, every lane is different
          width = 3, -- comes from street type
        },
        transportModes = {
          [1] = 0,
          [2] = 0,
          [3] = 1,
          [4] = 1,
          [5] = 1,
          [6] = 0,
          [7] = 0,
          [8] = 0,
          [9] = 0,
          [10] = 0,
          [11] = 0,
          [12] = 0,
          [13] = 0,
          [14] = 0,
          [15] = 0,
          [16] = 0,
        },
        speedLimit = 13.888889312744,
        curveSpeedLimit = 22.659643173218,
        curSpeed = 9.167142868042,
        precedence = false,
      },
      [5] = {
        conns = {
          [1] = {
            new = nil,
            entity = 74995, -- baseEdge.node0
            index = 5,
          },
          [2] = {
            new = nil,
            entity = 74996, -- baseEdge.node1
            index = 5,
          },
        },
        geometry = {
          params = {
            pos = {
              x = -5026.3291015625, -- position.x of node 74995 -- baseEdge.node0
              y = 2064.5080566406, -- position.y of node 74995 -- baseEdge.node0
            },
            tangent = {
              x = -56.029689788818, -- tangent0.x of edge
              y = 56.029323577881, -- tangent0.y of edge
            },
            offset = -4.5, -- comes from street type, it's always negative in two-way roads!
          },
          tangent = {
            x = 0.42324957251549, -- tangent0.z of edge
            y = -1.6819347143173, -- tangent1.z of edge
          },
          height = {
            x = 104.72540283203, -- position.z of node 74995 -- baseEdge.node0
            y = 103.38836669922, -- position.z of node 74996 -- baseEdge.node1
          },
          length = 77.216087341309, -- calculated, every lane is different
          width = 3, -- comes from street type
        },
        transportModes = {
          [1] = 0,
          [2] = 0,
          [3] = 0,
          [4] = 1,
          [5] = 1,
          [6] = 1,
          [7] = 1,
          [8] = 0,
          [9] = 0,
          [10] = 0,
          [11] = 0,
          [12] = 0,
          [13] = 0,
          [14] = 0,
          [15] = 0,
          [16] = 0,
        },
        speedLimit = 13.888889312744,
        curveSpeedLimit = 22.489542007446,
        curSpeed = 9.167142868042,
        precedence = false,
      },
      [6] = {
        conns = {
          [1] = {
            new = nil,
            entity = 74995, -- baseEdge.node0
            index = 0,
          },
          [2] = {
            new = nil,
            entity = 74996, -- baseEdge.node1
            index = 0,
          },
        },
        geometry = {
          params = {
            pos = {
              x = -5026.3291015625, -- position.x of node 74995 -- baseEdge.node0
              y = 2064.5080566406, -- position.y of node 74995 -- baseEdge.node0
            },
            tangent = {
              x = -56.029689788818, -- tangent0.x of edge
              y = 56.029323577881, -- tangent0.y of edge
            },
            offset = -7, -- comes from street type, it's always negative in two-way roads!
          },
          tangent = {
            x = 0.42324957251549, -- tangent0.z of edge
            y = -1.6819347143173, -- tangent1.z of edge
          },
          height = {
            x = 105.02540588379, -- same as in 1
            y = 103.68836975098, -- same as in 1
          },
          length = 76.234153747559, -- calculated, every lane is different
          width = 2, -- comes from street type
        },
        transportModes = {
          [1] = 1,
          [2] = 1,
          [3] = 0,
          [4] = 0,
          [5] = 0,
          [6] = 0,
          [7] = 0,
          [8] = 0,
          [9] = 0,
          [10] = 0,
          [11] = 0,
          [12] = 0,
          [13] = 0,
          [14] = 0,
          [15] = 0,
          [16] = 0,
        },
        speedLimit = 0,
        curveSpeedLimit = 0,
        curSpeed = 0,
        precedence = false,
      },
    },
  }